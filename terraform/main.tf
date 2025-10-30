# --- /terraform/main.tf ---

# Locals para Tablas de DynamoDB
locals {
  table_name = "example-${var.environment}"
  table_billing_mode = ""
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