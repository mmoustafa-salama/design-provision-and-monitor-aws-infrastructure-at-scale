# Define the variable for aws_region
variable "aws_region" {
  type = string
  default = "eu-central-1"
}

variable "function_name" {
    type = string
    default = "greeting_lambda_function"
}

variable "handler" {
    type = string
    default = "lambda.lambda_handler"
}

variable "runtime" {
    type = string
    default = "python3.8"
}