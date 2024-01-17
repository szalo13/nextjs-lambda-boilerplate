data "archive_file" "function_package" {
    type = "zip"
    source_dir = "${var.build_dir}"
    output_path = "deployment.zip"
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