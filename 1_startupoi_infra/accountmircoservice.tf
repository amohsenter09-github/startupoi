resource "aws_s3_bucket" "application-jars" {
  bucket = "application-jars-v3"

}

## This the application jar file that would be used in the elasticebeanstalk.
resource "aws_s3_bucket_object" "application-jar-file" {
  bucket = aws_s3_bucket.application-jars.id
  key    = "account-mircoservice-0.0.1.jar"
  source = "account-mircoservice-0.0.1-SNAPSHOT.jar"

}

# Create elastic beanstalk application
resource "aws_elastic_beanstalk_application" "accountmircoservice-app" {
  name = var.accountmircoservice-app
}

# Create elastic beanstalk Environment

resource "aws_elastic_beanstalk_application_version" "accountmircoservice-artificats-file" {
  name         = "v01"
  application  = var.accountmircoservice-app
  description  = "application version created by terraform"
  bucket       = aws_s3_bucket.application-jars.id
  key          = aws_s3_bucket_object.application-jar-file.id
  force_delete = true
}

resource "aws_elastic_beanstalk_environment" "accountmircoservice-evn" {
  name                = var.accountmircoservice-env
  application         = aws_elastic_beanstalk_application.accountmircoservice-app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.10 running Corretto 11"
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc.id
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
    name      = "ZULIP_ADMIN_NAME"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "duc.nguyen@startupoi.com"
  }
  setting {
    name      = "ZULIP_ADMIN_TOKEN"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "N1iiYtpY5LI91FP5vrYuXcWy6IhLE6vq"
  }
  setting {
    name      = "ZULIP_HOST"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "https://zlchat-dev.startupoi.com"
  }
  setting {
    name      = "ZULIP_TEMP-GENERATED-PASSWORD"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "Startup0i2020"
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
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = 7
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:monitoring"
    name      = "Automatically Terminate Unhealthy Instances"
    value     = "true"
  }
}
