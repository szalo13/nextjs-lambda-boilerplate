provider "aws" {
  region = var.region
  profile = var.profile
}

module "web" {
  source = "./web"
  profile = var.profile
  company_prefix = var.company_prefix
  environment = var.environment
  region = var.region
  module = "web"
  domain_name = "api.letsremote.agency"
  certificate_arn = "arn:aws:acm:eu-central-1:098079051172:certificate/46eae861-7b6e-4633-9fbe-e086997709fa"
}