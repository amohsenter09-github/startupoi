provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket               = "startupoi-tfstate"
    key                  = "terraform-vpc.tfstate"
    region               = "eu-west-1"
    workspace_key_prefix = "gd-tf-envs"
    dynamodb_table       = "environments-tflock"
  }
}

