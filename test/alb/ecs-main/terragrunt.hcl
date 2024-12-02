include {
  path = find_in_parent_folders()
}

locals {
  common_vars     = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name            = "ecs-alb"
}

terraform {
  source = "../../..//modules/terraform-aws-alb"
}

inputs = {
  name                        = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.name}"
  vpc_id                      = dependency.vpc.outputs.vpc_id
  load_balancer_type          = "application"
  subnets                     = dependency.vpc.outputs.public_subnets
  security_groups             = [dependency.sg_alb_main.outputs.security_group_id]
  enable_deletion_protection  = true

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Bad Request"
        status_code  = "400"
      }
    }
  ]

  tags = local.common_vars.tags
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "sg_alb_main" {
  config_path = "../../security-group/alb/"
}
