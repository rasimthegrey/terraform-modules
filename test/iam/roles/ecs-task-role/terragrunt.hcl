include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name        = "ecs-cloudwatchfullaccess-role"
}

terraform {
  source = "../../../../..//modules/terraform-aws-iam/modules/iam-assumable-role"
}

inputs = {
  trusted_role_services = ["ecs-tasks.amazonaws.com"]
  role_name             = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
  role_requires_mfa       = false
  create_role             = true

  tags = local.common_vars.tags
}