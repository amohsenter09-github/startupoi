provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket               = "startupoi-serverless-fstate"
    key                  = "terraform-serverless.tfstate"
    region               = "eu-west-1"
    workspace_key_prefix = "serverless-tf"
    dynamodb_table       = "environments-serverless-tflock"
  }
}

