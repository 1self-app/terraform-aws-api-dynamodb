# terraform-aws-api-dynamodb

Module to simplify DynamoDB integrations on API routes.

## Compatibility

This module is HCL2 compatible only.

## Example

```
resource "aws_api_gateway_rest_api" "api" {
  name = "api_dynamodb"
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = "api_dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
}

module "api-dynamodb" {
  source  = "barneyparker/api-dynamodb/aws"

  name = "ddb"
  api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id

  http_method = "POST"

  table_arn = aws_dynamodb_table.dynamodb.arn

    request_templates = {
    "application/json" = <<-EOT
      {
        "TableName": "${aws_dynamodb_table.dynamodb.name}",
        "Item": {
          "PK": {
            "S": "CONTACT#$input.path('$.email')"
          },
          "SK": {
            "S": "$context.requestTimeEpoch"
          },
          "id": {
            "S": "$context.requestId"
          }
          "name": {
            "S": "$input.path('$.name')"
          },
          "message": {
            "S": "$input.path('$.message')"
          }
        }
      }
    EOT
  }

  responses = [
    {
      status_code = "200"
      selection_pattern = "200"
      templates = {
        "application/json" = jsonencode({
          statusCode = 200
          message    = "OK"
        })
      }
    },
    {
      status_code = "400"
      selection_pattern = "4\\d{2}"
      templates = {
        "application/json" = jsonencode({
          statusCode = 400
          message    = "Error"
        })
      }
    }
  ]
}
```
