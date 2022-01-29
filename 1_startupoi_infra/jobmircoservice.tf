
# Create elastic beanstalk application
resource "aws_elastic_beanstalk_application" "jobmircoservice-app" {
  name = var.jobmircoservice-app
}

resource "aws_elastic_beanstalk_environment" "jobmircoservice-env" {
  name                = var.jobmircoservice-env
  application         = aws_elastic_beanstalk_application.jobmircoservice-app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.10 running Corretto 11"
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc.id
  }


  setting {
    name      = "ACCOUNT_SERVICE_URL"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = aws_elastic_beanstalk_environment.accountmircoservice-evn.endpoint_url ## This is the ALB endpoint of the microaccount service - and it is be registered as CNAM into the DNS server
  }

  setting {
    name      = "FILE_SERVICE_HOST"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = aws_elastic_beanstalk_environment.filetmircoservice-env.endpoint_url # This is the ALB endpoint of the file microservice - and it is be registered as CNAM into the DNS server
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
    name      = "JOB_SEARCH_SERVICE_URL"
    namespace = "aws:elasticbeanstalk:application:environment"
    value     = "${aws_instance.ec2-dev-jobsearchservice.public_dns}:8118/v1"
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
  depends_on = [
    aws_elastic_beanstalk_environment.accountmircoservice-evn, aws_elastic_beanstalk_environment.filetmircoservice-env, aws_instance.ec2-dev-jobsearchservice
  ]
}
