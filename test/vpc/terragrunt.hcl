include {
  path = find_in_parent_folders()
}

locals {
  common_vars            = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name                   = "vpc"
  azs                    = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  cidr                   = "10.0.0.0/16"
  public_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets        = ["10.0.11.0/24", "10.0.21.0/24", "10.0.31.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = false
}

terraform {
  source = "../..//modules/terraform-aws-vpc"
}

inputs = {
  name = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  azs  = local.azs
  cidr = local.cidr

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets

  # NAT Gateway Settings
  enable_nat_gateway     = local.enable_nat_gateway
  single_nat_gateway     = local.single_nat_gateway
  one_nat_gateway_per_az = local.one_nat_gateway_per_az
  enable_dns_hostnames   = local.enable_dns_hostnames

  tags = local.common_vars.tags
}