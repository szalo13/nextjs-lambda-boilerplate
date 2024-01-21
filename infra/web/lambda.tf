data "archive_file" "function_package" {
    type = "zip"
    source_dir = "${var.website_dir}/build"
    output_path = "${var.website_dir}/deployment.zip"
}

resource "aws_lambda_function" "dynamic_website_lambda" {
  filename = data.archive_file.function_package.output_path
  function_name = "${local.prefix}-website"
  role = aws_iam_role.lambda_role.arn
  handler = "run.sh"
  runtime = "nodejs20.x"
  architectures = [ "x86_64" ]
  layers = ["arn:aws:lambda:eu-central-1:753240598075:layer:LambdaAdapterLayerX86:7"]
  memory_size = 512
  timeout = 5
  source_code_hash = data.archive_file.function_package.output_base64sha256
  environment {
    variables = {
      "AWS_LAMBDA_EXEC_WRAPPER" = "/opt/bootstrap",
      "RUST_LOG" = "info",
      "PORT" = "8000",
      "NODE_ENV" = "production"
    }
  }
}

resource "aws_lambda_function_url" "dynamic-website-url" {
  function_name = aws_lambda_function.dynamic_website_lambda.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamic_website_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  // The 'source_arn' should match the ARN of your API Gateway endpoint
  source_arn = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*/*"
}