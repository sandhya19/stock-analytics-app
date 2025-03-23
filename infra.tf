#  DynamoDB Table
resource "aws_dynamodb_table" "stock_data" {
  name           = "StockData"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "symbol"
  range_key      = "timestamp"

  attribute {
    name = "symbol"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }
}

#  IAM Policy for DynamoDB Access
resource "aws_iam_policy" "dynamo_policy" {
  name = "DynamoDBPutItem"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["dynamodb:PutItem"],
      Effect   = "Allow",
      Resource = aws_dynamodb_table.stock_data.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamo_policy.arn
}

#  API Gateway
resource "aws_api_gateway_rest_api" "stock_api" {
  name = "StockAPI"
}

resource "aws_api_gateway_resource" "stock_resource" {
  rest_api_id = aws_api_gateway_rest_api.stock_api.id
  parent_id   = aws_api_gateway_rest_api.stock_api.root_resource_id
  path_part   = "fetch"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.stock_api.id
  resource_id   = aws_api_gateway_resource.stock_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.stock_api.id
  resource_id   = aws_api_gateway_resource.stock_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.stock_api.id
  resource_id             = aws_api_gateway_resource.stock_resource.id
  http_method             = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.stock_api.id
  resource_id = aws_api_gateway_resource.stock_resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.stock_api.id
  resource_id = aws_api_gateway_resource.stock_resource.id
  http_method = "OPTIONS"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.options_method,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_method_response.options_response
  ]
}




resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.stock_api.id
  resource_id             = aws_api_gateway_resource.stock_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.stock_fetcher.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_fetcher.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.stock_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.stock_api.id
  stage_name  = "prod"
}

# EventBridge Rule (Schedule Lambda every 5 min)
resource "aws_cloudwatch_event_rule" "stock_schedule" {
  name                = "StockFetchSchedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.stock_schedule.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.stock_fetcher.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stock_fetcher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stock_schedule.arn
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "frontend" {
  bucket = "stock-frontend-${random_id.suffix.hex}"
  


  website {
    index_document = "index.html"
    error_document = "index.html"
  }


  tags = {
    Name = "Stock Frontend Website"
  }
}

resource "aws_s3_bucket_ownership_controls" "frontend_controls" {
  bucket = aws_s3_bucket.frontend.id
  

  rule {
    object_ownership = "BucketOwnerPreferred"
    
  }
}

resource "aws_s3_bucket_public_access_block" "example_bucket_access_block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPutObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.module}/frontend/index.html"
  content_type = "text/html"
  acl          = "bucket-owner-full-control"
}

output "frontend_website_url" {
  value = aws_s3_bucket.frontend.website_endpoint
}

resource "aws_cloudfront_distribution" "frontend_cdn" {
  origin {
    domain_name = aws_s3_bucket.frontend.website_endpoint
    origin_id   = "s3Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3Origin"

    forwarded_values {
      query_string = true
      headers      = ["Origin"]
    
    cookies {
    forward = "none" 
    }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # Free SSL!
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Frontend CDN"
  }
}

output "cdn_url" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}