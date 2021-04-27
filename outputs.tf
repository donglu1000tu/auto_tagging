output "lambda_arn" {
  value = module.lambda_function.lambda_function_arn
  # depends_on = [
  #   module.lambda_function
  # ]
}

output "lambda_role" {
  value = module.lambda_function.lambda_role_arn
}

output "role_name" {
  value = module.lambda_function.lambda_role_name
}
output "name" {
  value = module.lambda_function.lambda_function_version
}
# output "region" {
#   value = 
# }