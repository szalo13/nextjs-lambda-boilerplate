variable "build_dir" {
  default = "../web/.build-standalone"
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