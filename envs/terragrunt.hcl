remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "net.malbolge.oni.tfstate"

    key = "echo/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

locals {
  common_vars = yamldecode(file("common_vars.yaml"))
  region      = local.common_vars.region
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  profile = "default"
  region  = "${local.region}"
}
EOF
}

terraform {
  source = "../../modules/echo"
}