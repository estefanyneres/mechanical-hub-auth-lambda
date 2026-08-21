data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "auth" {
  function_name = "${var.projectName}-auth"
  role          = local.labRole
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10
  memory_size   = 256

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.lambda_auth.id]
  }

  environment {
    variables = {
      DB_HOST     = data.aws_db_instance.main.address
      DB_PORT     = "5432"
      DB_NAME     = "mechanical_hub_db"
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      JWT_SECRET  = var.jwt_secret
    }
  }

  tags = var.tags
}
