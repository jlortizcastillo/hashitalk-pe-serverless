# --- /terraform/apigateway.tf ---

data "aws_caller_identity" "identity" {}

locals {
  api_name                        = "example-api-${var.environment}"
  api_endpoint_configuration_type = "REGIONAL"
  api_open_api_version            = "3.0.1"

  api_endpoints = {
    "/list" = { get = aws_lambda_function.lambda_function.function_name }
  }

  open_api_spec = {
    for endpoint, spec in local.api_endpoints : endpoint => {
      for method, lambda in spec : method => {

        responses = {
          200 = {
            headers = {
              Access-Control-Allow-Origin = {
                schema = {
                  type = "string"
                }
              }
              Access-Control-Allow-Methods = {
                schema = {
                  type = "string"
                }
              }
              Access-Control-Allow-Headers = {
                schema = {
                  type = "string"
                }
              }
            }
          }
        }

        x-amazon-apigateway-integration = {
          type       = "AWS_PROXY"
          httpMethod = "POST"
          uri        = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.identity.account_id}:function:${lambda}/invocations"
          responses = {
            default = {
              statusCode = "200"
              responseParameters = {
                "method.response.header.Access-Control-Allow-Headers" = "'Authorization,Content-Type,X-Amz-Date,X-Amz-Security-Token,X-Api-Key'"
                "method.response.header.Access-Control-Allow-Methods" = "'*'"
                "method.response.header.Access-Control-Allow-Origin"  = "'*'"
              }
              responseTemplates = {
                "application/json" = {}
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = local.api_name

  endpoint_configuration {
    types = [local.api_endpoint_configuration_type]
  }

  body = jsonencode({
    openapi = local.api_open_api_version
    paths   = local.open_api_spec
  })
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    timestamp = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.rest_api
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.environment
}