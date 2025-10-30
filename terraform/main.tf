# --- /terraform/main.tf ---

locals {
  # Locals para Tablas de DynamoDB
  table_name         = "example-${var.environment}"
  table_billing_mode = "PAY_PER_REQUEST" # "PROVISIONED"|"PAY_PER_REQUEST"

  # Locals para Funcion Lambda
  log_group_name           = "example-log-group-${var.environment}"
  log_group_retention_days = "7"
}

resource "aws_dynamodb_table" "example_table" {
  name         = local.table_name
  billing_mode = local.table_billing_mode
  hash_key     = "id"
  range_key    = "fechaCreacion"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "fechaCreacion"
    type = "S"
  }

  tags = {
    Name        = local.table_name
    Environment = var.environment
  }
}

# Cloudwatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = local.log_group_name
  retention_in_days = local.log_group_retention_days

  tags = {
    Name        = local.log_group_name
    Environment = var.environment
  }
}

