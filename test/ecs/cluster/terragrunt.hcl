include {
  path = find_in_parent_folders()
}

locals {
  common_vars        = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name               = "cluster"
  container_insights = true
  capacity_providers = ["FARGATE"]
}

terraform {
  source = "../../..//modules/terraform-aws-ecs-cluster"
}

inputs = {
  name               = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  container_insights = local.container_insights

  capacity_providers = local.capacity_providers
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
    }
  ]

  tags = local.common_vars.tags
}