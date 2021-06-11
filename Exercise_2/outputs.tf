# Define the output variable for the lambda function.
output "greeting_lambda_arn" {
  description = "The ARN of the Lambda Function"
  value = aws_lambda_function.greeting_lambda_function.arn
}
