# --- /terraform/iam.tf ---

# Lambda Permissions
data "aws_iam_policy_document" "lambda_permissions_document" {

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