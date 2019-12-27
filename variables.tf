variable "name_webhook" {
  description = "Name of webhook"
}

variable "domain" {
  description = "Domain name"
}

variable "domain_cert_arn" {
  description = "Certificate of domain"
}

variable "zone_domain" {
  description = "Zone domain id"
}

variable "lambda_invoke_arn" {
  description = "Lambda funtion arn"
}

variable "lambda_arn" {
  description = "Function lambda arn"
}

variable "region" {
  description = "Region"
  default     = "us-east-2"
}

variable "account_id" {
  description = "Account id"
}

variable "function_name" {
  description = "Function name of lambda"
}

variable "name_resource" {
  description = "Name of resource path"
}

variable "dns_record" {
  description = "DNS Record of domain"
}

variable "api_description" {
  description = "Description of API Method"
}
