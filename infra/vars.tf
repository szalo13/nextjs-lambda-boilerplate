variable "region" {
  description   = "AWS region"
  default       = "eu-central-1"
  type          = string
}

variable "profile" {
  description   = "AWS profile"
  default       = "letsremote"
  type          = string
}

variable "company_prefix" {
  description   = "Dashed prefix for resources"
  default       = "letsremote"
  type          = string
}

variable "environment" {
  description   = "Environment name"
  default       = "dev"
  type          = string
}