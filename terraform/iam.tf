# --- /terraform/iam.tf ---

locals {
  lambda_role_name              = "example-lambda-role-${var.environment}"
  lambda_policy_name            = "example-lambda-policy-${var.environment}"
  lambda_policy_attachment_name = "example-lambda-policy-attachment-${var.environment}"
}

# Lambda Assume Policy
data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json
}

# Lambda Policy Document
data "aws_iam_policy_document" "lambda_policy_document" {

  statement {
    sid    = "CloudWatchPermission"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda_log_group.arn}:*"
    ]
  }

  statement {
    sid = "DynamoDbPermissions"

    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.example_table.arn,
      "${aws_dynamodb_table.example_table.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name   = local.lambda_policy_name
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_policy_attachment" "lambda_policy_attach" {
  name       = local.lambda_policy_attachment_name
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}