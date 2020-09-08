variable "name" {}

variable "api_id" {}

variable "resource_id" {}

variable "http_method" {}

variable "table_arn" {}

variable "region" {}

variable "authorization" {
  default = "NONE"
}

variable "method_request_parameters" {
  type    = map
  default = {}
}

variable "integration_request_parameters" {
  type    = map
  default = {}
}

variable "request_templates" {
  type    = map
  default = {}
}

variable "responses" {
  type    = list
  default = []
}

variable "authorizer_id" {
  default     = null
  description = "The authorizer id to be used when the authorization is `CUSTOM` or `COGNITO_USER_POOLS`"
}
