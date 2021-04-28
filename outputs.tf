output "lambda_arn" {
  value = aws_lambda_function.auto_tagging.arn
  # depends_on = [
  #   module.lambda_function
  # ]
}

output "lambda_role" {
  value = aws_lambda_function.auto_tagging.role
}

output "version" {
  value = aws_lambda_function.auto_tagging.version
}