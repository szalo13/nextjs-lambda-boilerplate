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
}