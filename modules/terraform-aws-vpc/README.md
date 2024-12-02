# Terraform AWS VPC Module

## Example Terragrunt Configuration

- **terragrunt.hcl (main configuration)**

```
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "eu-central-1"
  profile = "sufle-dev"
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket  = "test-terragrunt-state"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "eu-central-1"
    encrypt = true
    profile = "sufle-dev"
  }
}
```

- **common-vars.yaml**

```
namespace: sufle
environment: test

tags:
  Namespace: sufle
  Environment: test
  Terraform: true
```

- **/vpc/terragrunt.hcl**

```
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
  database_subnets       = ["10.0.12.0/24", "10.0.22.0/24", "10.0.33.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
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
  database_subnets = local.database_subnets

  # NAT Gateway Settings
  enable_nat_gateway     = local.enable_nat_gateway
  single_nat_gateway     = local.single_nat_gateway
  one_nat_gateway_per_az = local.one_nat_gateway_per_az
  enable_dns_hostnames   = local.enable_dns_hostnames

  tags = local.common_vars.tags
}
```

This configuration creates a VPC within 3 public, 3 private and, 3 database subnets. Also enables NAT Gateway and DNS Hostnames.