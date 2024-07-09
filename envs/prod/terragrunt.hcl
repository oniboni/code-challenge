include "root" {
    path = find_in_parent_folders()
}

locals {
    common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))

    environment = get_env("ENV_NAME", "prod")
    
    name_prefix  = local.common_vars.name_prefix
    domain_name  = local.common_vars.domain_name
}

inputs = {
  environment = local.environment
  name_prefix = "${local.name_prefix}.${local.environment}-lightsail"
  domain_name = local.domain_name

  tags = {
      Environment = local.environment
      Name = local.name_prefix
  }
}