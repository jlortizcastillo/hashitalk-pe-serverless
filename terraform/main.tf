# --- /terraform/main.tf ---

locals {
  # Locals para Tablas de DynamoDB
  table_name         = "example-${var.environment}"
  table_billing_mode = "PAY_PER_REQUEST" # "PROVISIONED"|"PAY_PER_REQUEST"

  # Locals para CloudWatch
  log_group_name = "example-log-group-${var.environment}"

  # Locals para Lambda
  lambda_requirements      = false
  lambda_root_directory    = "../lambdas"
  lambda_code_folder       = "example"
  lambda_file_source_dir   = "${local.lambda_root_directory}/${local.lambda_code_folder}"
  lambda_requirements_path = "${local.lambda_file_source_dir}/requirements.txt"
  lambda_file_type         = "zip"
  lambda_name              = "example-function-${var.environment}"
  lambda_file_output_path  = "${local.lambda_root_directory}/${local.lambda_name}.zip"
  lambda_file_name         = "app"
  lambda_handler           = "${local.lambda_file_name}.lambda_handler"
  lambda_handler_path      = "${local.lambda_file_source_dir}/${local.lambda_file_name}.py"
  lambda_runtime           = "python3.11"
  lambda_timeout           = "30" # En Segundos
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
  name = local.log_group_name

  tags = {
    Name        = local.log_group_name
    Environment = var.environment
  }
}

# Lambda Function
resource "null_resource" "lambda_dependencies" {
  count = local.lambda_requirements ? 1 : 0

  triggers = {
    #handler      = filesha1("${local.lambda_handler_path}")
    #requirements = filesha1("${local.lambda_requirements_path}")
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      pip install -r ${local.lambda_requirements_path} -t ${local.lambda_file_source_dir}/package
    EOF
  }
}

data "archive_file" "lambda_package" {
  type        = local.lambda_file_type
  source_dir  = local.lambda_file_source_dir
  output_path = local.lambda_file_output_path

  depends_on = [null_resource.lambda_dependencies]
}

resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = local.lambda_name
  handler          = local.lambda_handler
  role             = aws_iam_role.lambda_role.arn
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  timeout          = local.lambda_timeout

  # environment {
  #   variables = local.lambda_variables
  # }

  tags = {
    Name        = local.lambda_name
    Environment = var.environment
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_log_group,
    aws_iam_policy_attachment.lambda_policy_attach,
    data.archive_file.lambda_package
  ]
}