# Designate a cloud provider, region, and credentials
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_iam_role_policy" "greeting_lambda_policy" {
  name        = "greeting_lambda_policy"
  role        = "${aws_iam_role.greeting_lambda_role.id}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeInstances",
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
})
}


resource "aws_iam_policy" "greeting_lambda_logging_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "greeting_lambda_role" {
  name = "greeting_lambda_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "greeting_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.greeting_lambda_role.name
  policy_arn = aws_iam_policy.greeting_lambda_logging_policy.arn
}

resource "aws_vpc" "udacity_vpc" {
  cidr_block = "10.3.0.0/16"
  tags = {
    Name = "Udacity-VPC"
  }
}

resource "aws_subnet" "udacity_subnet" {
  vpc_id     = aws_vpc.udacity_vpc.id
  cidr_block = "10.3.1.0/24"

  tags = {
    Name = "Udacity-Subnet"
  }
}

resource "aws_security_group" "udacity_security_group" {
  name        = "udacity_security_group"
  vpc_id      = aws_vpc.udacity_vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Udacity-Security-Group"
  }
}


data "archive_file" "lambda" {
  type = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "greeting_lambda_function" {
  function_name = "${var.function_name}"
  role          = aws_iam_role.greeting_lambda_role.arn
  handler       = "${var.handler}"
  runtime       = "${var.runtime}"

  vpc_config {
    # vpc_id = aws_vpc.udacity_vpc.id
    subnet_ids         = [aws_subnet.udacity_subnet.id]
    security_group_ids = [aws_security_group.udacity_security_group.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.greeting_log_group,
  ]

  filename      = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
}