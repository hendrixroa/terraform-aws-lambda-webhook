// Api Gateway rest api resource of `Regional` type
resource "aws_api_gateway_rest_api" "main" {
  name        = var.name_webhook
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

// Custom domain name user friendly readable to hit into API.
resource "aws_api_gateway_domain_name" "main" {
  domain_name              = var.domain
  regional_certificate_arn = var.domain_cert_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id        = aws_api_gateway_deployment.main.id
  stage_name           = var.name_webhook
  rest_api_id          = aws_api_gateway_rest_api.main.id
  xray_tracing_enabled = true
}

// Resource to deploy the current API Rest to be available to hit it.
resource "aws_api_gateway_deployment" "main" {

  depends_on = [
    "aws_api_gateway_rest_api.main",
    "aws_api_gateway_resource.main",
    "aws_api_gateway_method.main",
    "aws_api_gateway_integration.main",
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.name_webhook
}

// Resource to link the user friendly domain name with the current api deployment.
resource "aws_api_gateway_base_path_mapping" "main" {
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_deployment.main.stage_name
  domain_name = aws_api_gateway_domain_name.main.domain_name
  base_path   = var.name_webhook

  depends_on = [
    "aws_api_gateway_deployment.main",
  ]
}

// DNS Record for the user friendly domain of Webhook
resource "aws_route53_record" "dns_webhook" {
  name    = var.dns_record
  type    = "CNAME"
  zone_id = var.zone_domain
  ttl     = "300"
  records = [aws_api_gateway_domain_name.main.regional_domain_name]
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = var.name_resource
}

resource "aws_api_gateway_method" "main" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.main.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_method.main.resource_id
  http_method = aws_api_gateway_method.main.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"

  request_templates = {
    "application/json" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowAPIGatewayInvoke_${var.name_webhook}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.main.http_method}${aws_api_gateway_resource.main.path}"
}
