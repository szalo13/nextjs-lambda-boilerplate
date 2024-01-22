resource "aws_api_gateway_rest_api" "web_api" {
  name = var.module
}

# Proxy resource to handle subroutes
resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.web_api.id
  parent_id   = aws_api_gateway_rest_api.web_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.web_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Main resource to handle root route
resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.web_api.id
  resource_id   = aws_api_gateway_rest_api.web_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id             = aws_api_gateway_rest_api.web_api.id
  resource_id             = aws_api_gateway_rest_api.web_api.root_resource_id
  http_method             = aws_api_gateway_method.root_method.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.dynamic_website_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id   = aws_api_gateway_rest_api.web_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = aws_api_gateway_method.root_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamic_website_lambda.invoke_arn

  cache_key_parameters = ["method.request.path.proxy"]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "web_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.web_api.id
  stage_name  = "${var.environment}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_domain_name" "web_domain" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"] // or EDGE
  }
}

resource "aws_api_gateway_stage" "web_stage" {
  stage_name    = "${var.environment}_stage"
  rest_api_id   = aws_api_gateway_rest_api.web_api.id
  deployment_id = aws_api_gateway_deployment.web_deployment.id

  description = "${var.environment} stage"
  xray_tracing_enabled = true  // Enable X-Ray tracing, if needed

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.web_loggroup.arn
    format = "{ \"requestId\": \"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\": \"$context.identity.caller\", \"user\": \"$context.identity.user\", \"requestTime\": \"$context.requestTime\", \"httpMethod\": \"$context.httpMethod\", \"resourcePath\": \"$context.resourcePath\", \"status\": \"$context.status\", \"protocol\": \"$context.protocol\", \"responseLength\": \"$context.responseLength\" }"
  }

  variables = {
    "variableName" = "variableValue"
  }
}

resource "aws_cloudwatch_log_group" "web_loggroup" {
  name = "/aws/apigateway/${local.prefix}"
}

resource "aws_api_gateway_base_path_mapping" "web_base_path" {
  api_id      = aws_api_gateway_rest_api.web_api.id
  stage_name  = aws_api_gateway_stage.web_stage.stage_name
  domain_name = aws_api_gateway_domain_name.web_domain.domain_name

  depends_on = [aws_api_gateway_stage.web_stage]
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_attach" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = aws_iam_policy.api_gateway_cloudwatch_policy.arn
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = "api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ],
  })
}

resource "aws_iam_policy" "api_gateway_cloudwatch_policy" {
  name = "api-gateway-cloudwatch-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect = "Allow",
      Resource = "arn:aws:logs:*:*:*"
    }],
  })
}