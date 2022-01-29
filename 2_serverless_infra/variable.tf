variable "region" {
  description = "The region to deploy the lambda in eu-west-1"
  type        = string
  default     = "eu-west-1"
}

variable "lambda_name" {
  type = list(string)
  default = [
    "startupoi-pre-sign-up-cognito",
    "startupoi-post-confirmation",
    "getPresignedURL"
  ]
}


variable "filename" {
  type = list(string)
  default = [
    "getPresignedURL.zip",
    "startupoi-post-confirmation.zip",
    "startupoi-pre-sign-up-cognito-.zip"
  ]
}
