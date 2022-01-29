resource "aws_s3_bucket" "bucket" {
  bucket = var.terraform_state_bucket
  tags = var.common_tags
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.terraform_state_dynamodb_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

## The indpendent store state for the serverless function only.

resource "aws_s3_bucket" "serverless-bucket" {
  bucket = var.terraform_serverless_state_bucket
  tags = var.serverless-common_tags
}

resource "aws_dynamodb_table" "terraform_serverless_state_lock" {
  name           = var.terraform_serverless_state_dynamodb_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}