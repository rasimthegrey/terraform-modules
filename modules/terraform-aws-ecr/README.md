# Terraform AWS Elastic Container Registry Module

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

- **/ecr/terragrunt.hcl**

```
include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "app"
}

terraform {
  source = "../../../..//modules/terraform-aws-ecr"
}

inputs = {
  name = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  repository_lifecycle_policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
  tags = local.common_vars.tags
}

```

This configuration creates an ECR repository and attaches a lifecycle policy.