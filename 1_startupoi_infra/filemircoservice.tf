

# Create elastic beanstalk application
resource "aws_elastic_beanstalk_application" "filemircoservice-app" {
  name = var.filemircoservice-app
}

data "aws_secretsmanager_secret" "secrets" {
  arn = "arn:aws:secretsmanager:eu-west-1:159231561593:secret:filemircroservice-aws-access-key-G0N2n9"

}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

resource "aws_elastic_beanstalk_environment" "filetmircoservice-env" {
  name                = var.filetmircoservice-env
  application         = aws_elastic_beanstalk_application.filemircoservice-app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.10 running Corretto 11"
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = true
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = true
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = 7
    resource  = ""
  }

  setting {
    name      = "APPLICATION_BUCKET_AVATAR_NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "startupoi-dev/user_avatar"
  }

  setting {
    name      = "CLOUD_AWS_CREDENTIALS_ACCESS-KEY"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["CLOUD_AWS_CREDENTIALS_ACCESS-KEY"]
  }

  setting {
    name      = "CLOUD_AWS_CREDENTIALS_SECRET-KEY"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["CLOUD_AWS_CREDENTIALS_SECRET-KEY"]
  }

  setting {
    name      = "CLOUD_AWS_REGION_STATIC"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["CLOUD_AWS_REGION_STATIC"]
  }

  setting {
    name      = "APPLICATION_BUCKET_CV_NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "startupoi-dev/user_cv"
  }

  setting {
    name      = "GRADLE_HOME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "/usr/local/gradle"
  }
  setting {
    name      = "JAVA_HOME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "/usr/lib/jvm/java-11-amazon-corretto.x86_64"
  }
  setting {
    name      = "M2"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "/usr/local/apache-maven/bin"
  }
  setting {
    name      = "M2_HOME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "/usr/local/apache-maven"
  }
  setting {
    name      = "RDS_DB_NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = local.username_password_dbname.database_name
  }
  setting {
    name      = "RDS_HOSTNAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = trim(module.db.db_instance_endpoint, ":3306")
  }
  setting {
    name      = "RDS_PASSWORD"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = local.username_password_dbname.password
  }
  setting {
    name      = "RDS_PORT"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "3306"
  }
  setting {
    name      = "RDS_USERNAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = local.username_password_dbname.username
  }
  setting {
    name      = "SPRING_PROFILES_ACTIVE"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "dev"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", aws_subnet.public_subnets.*.id)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type[0]
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 2
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:monitoring"
    name      = "Automatically Terminate Unhealthy Instances"
    value     = "true"
  }
}
