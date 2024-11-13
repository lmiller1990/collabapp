variable "environment" {
  type = string
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "lambda:InvokeFunction"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",     # Include this if you need to write to DynamoDB
          "dynamodb:Query",       # Include this if you need to run queries
          "dynamodb:Scan"         # Include this if you need to scan the table
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.collab.arn
      },
      {
        Action = [
          "s3:ListBucket",         # Grants permission to list objects in the bucket
          "s3:GetObject"           # Grants permission to retrieve objects from the bucket
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::lachlan-collab-${var.environment}",
          "arn:aws:s3:::lachlan-collab-${var.environment}/*",
          "arn:aws:s3:::lachlan-collab-documents-${var.environment}",
          "arn:aws:s3:::lachlan-collab-documents-${var.environment}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "fastapi_test" {
  function_name = "fastapi_test_fn"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "collab.app.handler"
  runtime       = "python3.12"
  filename      = "lambda.zip"

  source_code_hash = filebase64sha256("lambda.zip")
}

# Dynamo 
resource "aws_dynamodb_table" "collab" {
  name           = "collab"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "my_api" {
  name = "MyAPIGateway"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "any_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.any_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fastapi_test.invoke_arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fastapi_test.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "my_deployment" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "dev"

  depends_on = [
   aws_api_gateway_integration.proxy_integration,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_method_response.options_response_200,
    aws_api_gateway_integration_response.options_integration_response_200
  ]
}

resource "aws_cloudwatch_log_group" "api_gw_logging" {
  name              = "/aws/api-gateway/MyAPIGateway"
  retention_in_days = 7
}

output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.my_deployment.invoke_url}/app"
  description = "The base URL of the API Gateway endpoint"
}

# frontend
# Frontend assets S3

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "lachlan-collab-${var.environment}"

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "documents" {
  bucket = "lachlan-collab-documents-${var.environment}"
}

resource "aws_s3_bucket_website_configuration" "static_assets_website" {
  bucket = aws_s3_bucket.static_assets.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_policy" "static_assets_policy" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.example]
}

# Ensure public access block is not preventing public policies
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls   = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls  = false
}

# resource "aws_cloudfront_distribution" "cdn" {
#   origin {
#     domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
#     origin_id   = "S3-static-assets"
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "Static assets CDN"

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-static-assets"
    
#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }
    
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     # Use ACM or a custom SSL certificate
#     acm_certificate_arn      = "your-acm-certificate-arn"
#     ssl_support_method       = "sni-only"
#   }
# }



# Deploy resources using a local script
resource "null_resource" "deploy_resources" {
  provisioner "local-exec" {
    command = <<EOT
      # Set API endpoint and build
      export VITE_API_ENDPOINT=${aws_api_gateway_deployment.my_deployment.invoke_url}
      cd frontend
      pnpm run build

      # Sync to S3
      aws s3 sync dist s3://${aws_s3_bucket.static_assets.bucket}/

      # Invalidate CloudFront distribution
    EOT
      # aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.cdn.id} --paths "/*"
  }

  triggers = {
    redeploy_time = timestamp()  # Forces execution whenever `terraform apply` is run
  }

  # Ensure this runs after the creation of S3 and CloudFront
  depends_on = [
    aws_s3_bucket.static_assets,
    aws_api_gateway_deployment.my_deployment
    # aws_cloudfront_distribution.cdn
  ]
}

resource "null_resource" "build_lambda" {
  provisioner "local-exec" {
    command = "./lambda.sh"
  }

  # Optional: Add triggers to determine when to rerun the script
  triggers = {
    build_time = timestamp()  # This will run every time
  }
}

resource "aws_api_gateway_method" "options_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = aws_api_gateway_method.options_proxy.http_method
  type          = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response_200" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  status_code = aws_api_gateway_method_response.options_response_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}