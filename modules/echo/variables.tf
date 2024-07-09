variable "tags" {
  description = "tags supplied by terragrunt"
  type        = map(any)
}

variable "name_prefix" {
  description = "name prefix supplied by terragrunt"
  type        = string
}

variable "environment" {
  description = "Environment name supplied by terragrunt"
  type = string
}

variable "domain_name" {
  description = "Domain name supplied by terragrunt, DNS zone has to be present in advance"
  type = string
}