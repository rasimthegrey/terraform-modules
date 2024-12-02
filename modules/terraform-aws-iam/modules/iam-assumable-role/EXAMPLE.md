# Terraform AWS IAM Assumable Role Module

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

- **/iam/roles/ssm/terragrunt.hcl**

```
include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "ssm-ec2access-role"
}

terraform {
  source = "../../../..//modules/terraform-aws-iam/modules/iam-assumable-role"
}

inputs = {
  trusted_role_services = ["ec2.amazonaws.com"]
  role_name             = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  tags = local.common_vars.tags
}
```