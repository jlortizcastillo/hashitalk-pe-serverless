# --- /terraform/outputs.tf ---

# API GATEWAY
output "api_gateway_rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}

# DYNAMODB
output "dynamodb_table_name" {
  value = aws_dynamodb_table.example_table.name
}

# LAMBDA
output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "lambda_iam_policy_name" {
  value = aws_iam_policy.lambda_iam_policy.name
}