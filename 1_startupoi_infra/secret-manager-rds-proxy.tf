resource "random_password" "admin_password" {
  count            = var.rds_password == "" || var.rds_password == null ? 1 : 0
  length           = 33
  special          = false
  override_special = "!#$%^&*()<>-_"
}

locals {
  database_password = var.rds_password != "" && var.rds_password != null ? var.rds_password : join("", random_password.admin_password.*.result)

  username_password_dbname = {
    dbInstanceIdentifier = var.identifier
    username             = var.rds_username
    password             = local.database_password
    database_name        = var.database_name

  }
}


locals {
  environment-name = "dev"
}

resource "aws_secretsmanager_secret" "db-secrets" {
  name                    = "rds-proxy-_v6-secret"
  recovery_window_in_days = 0
}

# Credentials that corespond to a db user in RDS (need to add "host": "${module.db.db_instance_endpoint}",)
resource "aws_secretsmanager_secret_version" "db-secrets" {
  lifecycle { ignore_changes = [secret_string] }
  secret_id     = aws_secretsmanager_secret.db-secrets.name
  secret_string = <<EOF
{
"username": "${local.username_password_dbname.username}",
"engine": "mysql",
"dbname": "${local.username_password_dbname.database_name}",
"password": "${local.username_password_dbname.password}",
"port": 3306,
"dbInstanceIdentifier": "${local.username_password_dbname.dbInstanceIdentifier}"
}
EOF

}

resource "aws_iam_policy" "policy" {
  name        = "${local.environment-name}-rds-proxy-policy"
  description = "Policy for creating rds-proxy-role-policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetRandomPassword",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "role" {
  name               = "${local.environment-name}-rds-proxy-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_db_proxy" "rds-proxy" {
  name                   = "${local.environment-name}-rds-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.role.arn
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  vpc_subnet_ids         = aws_subnet.public_subnets.*.id

  auth {
    auth_scheme = "SECRETS"
    description = "test-secret"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_secretsmanager_secret_version.db-secrets.arn
  }
}

resource "aws_db_proxy_endpoint" "rds-proxy" {
  db_proxy_name          = aws_db_proxy.rds-proxy.name
  db_proxy_endpoint_name = "${local.environment-name}-rds-proxy"
  vpc_subnet_ids         = aws_subnet.public_subnets.*.id
  vpc_security_group_ids = aws_security_group.rds.*.id
  target_role            = "READ_ONLY"
}

resource "aws_db_proxy_default_target_group" "rds-proxy" {
  db_proxy_name = aws_db_proxy.rds-proxy.name
  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

resource "aws_db_proxy_target" "rds-proxy" {
  db_instance_identifier = var.identifier

  db_proxy_name     = aws_db_proxy.rds-proxy.name
  target_group_name = aws_db_proxy_default_target_group.rds-proxy.name
  depends_on = [
    module.db
  ]
}
