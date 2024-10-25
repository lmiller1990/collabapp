provider "aws" {
  region = "ap-southeast-2"  # Use your desired region
}

resource "aws_lambda_function" "fastapi_test" {
  function_name = "fastapi_test_fn"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "collab.app.handler"
  runtime       = "python3.12"
  filename      = "lambda.zip"

  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
