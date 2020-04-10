resource "aws_api_gateway_method" "method" {
  rest_api_id        = var.api_id
  resource_id        = var.resource_id
  http_method        = var.http_method
  authorization      = var.authorization
  request_parameters = var.request_parameters
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:eu-west-1:dynamodb:action/PutItem"
  credentials             = aws_iam_role.dynamodb_put.arn
  request_templates = var.request_templates
}

resource "aws_api_gateway_integration_response" "integration_response" {
  count = length(var.responses)

  rest_api_id        = var.api_id
  resource_id        = var.resource_id
  http_method        = aws_api_gateway_method.method.http_method
  status_code        = var.responses[count.index].status_code
  selection_pattern  = var.responses[count.index].selection_pattern
  response_templates = var.responses[count.index].templates
}

resource "aws_api_gateway_method_response" "method_response_200" {
  count = length(var.responses)

  rest_api_id = var.api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.method.http_method
  status_code = var.responses[count.index].status_code
}

resource "aws_iam_role" "dynamodb_put" {
  name = "${var.name}-ddb-put"
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

resource "aws_iam_role_policy" "dynamodb_put" {
  name = "DynamoDB-Put-Item"
  role = aws_iam_role.dynamodb_put.id
  policy = data.aws_iam_policy_document.dynamodb_put.json
}

data "aws_iam_policy_document" "dynamodb_put" {
  statement {
     actions = [
      "dynamodb:PutItem",
    ]

    resources = [
      "${var.table_arn}",
    ]
  }
}