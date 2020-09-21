module "dynamodb_integration" {
  source = "github.com/1self-io/terraform-aws-api-generic"

  name                           = var.name
  api_id                         = var.api_id
  resource_id                    = var.resource_id
  http_method                    = var.http_method
  authorization                  = var.authorization
  authorizer_id                  = var.authorizer_id
  method_request_parameters      = var.method_request_parameters
  integration_request_parameters = var.integration_request_parameters

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${format("arn:aws:apigateway:%s:dynamodb:action/%s", var.region, var.integration_action)}"
  credentials             = aws_iam_role.this.arn
  request_templates       = var.request_templates

  responses = var.responses
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-ddb-${var.integration_action}"
  assume_role_policy = data.aws_iam_policy_document.apigw.json
}

data "aws_iam_policy_document" "apigw" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-DynamoDB-${var.integration_action}"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "dynamodb:${var.integration_action}",
    ]

    resources = [
      "${var.table_arn}",
      "${var.table_arn}/index/*"
    ]
  }
}
