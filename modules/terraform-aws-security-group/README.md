# Terraform AWS Security Group Module

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

- **/sg/alb/terragrunt.hcl**

```
include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "test-alb-sg"
}

terraform {
  source = "../../..//modules/terraform-aws-security-group"
}

inputs = {
  name        = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  description = "Security group for Test ALB"
  vpc_id      = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access from everywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access from everywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound connections"
    }
  ]

  tags = local.common_vars.tags
}

dependency "vpc" {
  config_path = "../../vpc"
}

```

This configuration creates a Security Group for an Application Load Balancer.