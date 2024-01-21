variable "website_dir" {
  default = "../web"
}

variable "profile" {
  type = string
  default = ""
}

variable "company_prefix" {
  type = string
  default = ""
}

variable "environment" {
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "eu-central-1"
}

variable "module" {
  type = string
  default = "web"
}

variable "domain_name" {
  description = "The domain name for the website"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate in AWS Certificate Manager"
  type        = string
}