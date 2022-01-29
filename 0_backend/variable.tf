variable "aws_region" {
  type = string
  default = "eu-west-1"
}
###############################################################
#This the variables for the newtwork,rds and microservice state-store - it provision resources in folder startupoi_infra
variable "terraform_state_bucket" {
  description = "Name of S3 bucket to store terraform state file"
  type        = string
  default     = "startupoi-tfstate"
}

variable "terraform_state_dynamodb_name" {
  description = "Name of dynamodb name for storing terraform lock"
  type        = string
  default     = "environments-tflock"
}


variable "common_tags" {
  type = map(string)
  default = {
  Owner        = "amohsen"
  Service      = "The base VPC infrastructure"
  Product      = "startupoi"
}
}

###############################################################
#This the variables for the serverless state-store - it provision resources in folder 2_serverless_infra
variable "terraform_serverless_state_bucket" {
  description = "Name of S3 bucket to store terraform state file specfically for serverless resource"
  type        = string
  default     = "startupoi-serverless-fstate"
}

variable "terraform_serverless_state_dynamodb_name" {
  description = "Name of dynamodb name for storing terraform lock"
  type        = string
  default     = "environments-serverless-tflock"
}


variable "serverless-common_tags" {
  type = map(string)
  default = {
  Owner        = "amohsen"
  Service      = "The base serverless infrastructure"
  Product      = "serverless-startupoi"
}
}