output "lambda_arn" {
  description = "ARN da Lambda de autenticacao de clientes, para o API Gateway"
  value       = aws_lambda_function.auth.arn
}

output "lambda_function_name" {
  description = "Nome da funcao Lambda"
  value       = aws_lambda_function.auth.function_name
}
