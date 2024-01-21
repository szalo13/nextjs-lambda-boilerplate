resource "aws_api_gateway_rest_api" "example_api" {
  name = var.module
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method = aws_api_gateway_method.example_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.dynamic_website_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "${var.environment}"
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_deployment.example_deployment.invoke_url}"
}

resource "aws_api_gateway_domain_name" "example_domain" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"] // or EDGE
  }
}

resource "aws_api_gateway_stage" "example_stage" {
  stage_name    = var.environment
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  deployment_id = aws_api_gateway_deployment.example_deployment.id

  description = "${var.environment} stage"
  xray_tracing_enabled = true  // Enable X-Ray tracing, if needed

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.example.arn
    format = "{ \"requestId\": \"$context.requestId\", \"ip\": \"$context.identity.sourceIp\", \"caller\": \"$context.identity.caller\", \"user\": \"$context.identity.user\", \"requestTime\": \"$context.requestTime\", \"httpMethod\": \"$context.httpMethod\", \"resourcePath\": \"$context.resourcePath\", \"status\": \"$context.status\", \"protocol\": \"$context.protocol\", \"responseLength\": \"$context.responseLength\" }"
  }

  variables = {
    "variableName" = "variableValue"
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/apigateway/${local.prefix}"
}

resource "aws_api_gateway_base_path_mapping" "example_base_path" {
  api_id      = aws_api_gateway_rest_api.example_api.id
  stage_name  = aws_api_gateway_stage.example_stage.stage_name
  domain_name = aws_api_gateway_domain_name.example_domain.domain_name
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

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_attach" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = aws_iam_policy.api_gateway_cloudwatch_policy.arn
}