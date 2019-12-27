# Lambda Webhook

Lambda module with API Gateway integration for deploy custom webhooks very cheaper (Almost free)
Ready to use with [Lambda node.js](https://github.com/hendrixroa/terraform-aws-lambda-nodejs-yarn) module or whatever you prefer.

- Terraform: `0.12.+`

## How to use

```hcl
module "your_awesome_webhook" {
  source            = "hendrixroa/lambda-webhook/aws"
  api_description   = "Your awesome description"
  name_webhook      = "nameWebhook"
  name_resource     = "nameResource"
  dns_record        = "nameWebhook"
  domain            = "nameWebhook.domain.com"
  domain_cert_arn   = "certificate arn"
  zone_domain       = "Zone domain id"
  lambda_invoke_arn = module.lambda.invoke_arn
  lambda_arn        = module.lambda.lambda_arn
  account_id        = data.aws_caller_identity.current.account_id
  function_name     = module.lambda.function_name
}
```
