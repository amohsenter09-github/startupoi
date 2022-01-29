# security groups
resource "aws_security_group" "rds" {
  name        = "rds_security_group"
  description = "Terraform RDS MySQL server"
  vpc_id      = aws_vpc.vpc.id

  # to consider keeping the instance private by only allowing traffic from the web server.
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr_block}"]

  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds-security-group"
  }
}


# Only uncomment in these lines in case of restoring production database
data "aws_db_snapshot" "db_snapshot" {
  most_recent            = true
  db_instance_identifier = "rdsdvdb"
}
output "rds" {
  value = data.aws_db_snapshot.db_snapshot
}
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier        = var.identifier
  engine            = "mysql"
  engine_version    = "8.0.23"
  instance_class    = "db.t3.2xlarge"
  allocated_storage = 100

  name                                = local.username_password_dbname.database_name
  username                            = local.username_password_dbname.username
  password                            = local.username_password_dbname.password
  port                                = "3306"
  publicly_accessible                 = true
  iam_database_authentication_enabled = true
  snapshot_identifier                 = data.aws_db_snapshot.db_snapshot.id
  vpc_security_group_ids              = ["${aws_security_group.rds.id}"]

  maintenance_window  = "Mon:00:00-Mon:03:00"
  backup_window       = "03:00-06:00"
  skip_final_snapshot = true
  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = aws_subnet.public_subnets.*.id

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  depends_on = [
    aws_secretsmanager_secret.db-secrets, aws_secretsmanager_secret_version.db-secrets
  ]
}
