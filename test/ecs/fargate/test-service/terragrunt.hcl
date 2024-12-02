include {
  path = find_in_parent_folders()
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  name = "test-app-service"
  role_name = "${local.name}-role"
  task_role_name = "${local.name}-task-role"
  log_region = "eu-central-1"
}

terraform {
  source = "../../../..//modules/terraform-aws-ecs-fargate"
}

inputs = {
  namespace = local.common_vars.namespace
  environment = local.common_vars.environment
  task_name = local.name
  task_cpu = 512
  task_memory = 1024

  cluster_id = dependency.cluster.outputs.ecs_cluster_id
  cluster_name = dependency.cluster.outputs.ecs_cluster_name
  service_subnets = dependency.vpc.outputs.private_subnets
  service_security_groups = [dependency.sg_ecs_test_app.outputs.security_group_id]

  scaling_enabled = true
  desired_count = 2
  max_capacity = 6
  min_capacity = 2
  target_cpu = 80

  stickiness_enabled = true
  stickiness_cookie_duration = 86400
  stickiness_type            = "lb_cookie"

  task_role_enabled       = true
  iam_task_role_name      = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.task_role_name}"
  iam_execution_role_name = "${local.common_vars.namespace}-${local.common_vars.environment}-${local.role_name}"
 

  target_group_name        = "${local.common_vars.namespace}-${local.common_vars.environment}-test-app"
  vpc_id                   = dependency.vpc.outputs.vpc_id
  aws_lb_listener_arn      = dependency.alb.outputs.http_tcp_listener_arns[0]
  aws_lb_listener_priority = 1
  health_check_path        = "/"
  health_check_protocol    = "HTTP"

  log_region            = local.log_region
  log_retention_in_days = 90

  app_container_name   = "${local.name}-app"
  app_container_image  = "${dependency.ecr_app.outputs.repository_url}:latest"
  app_container_cpu    = 256
  app_container_memory = 512
  app_port_mappings = [
    {
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }
  ]

  create_varnish = true
  varnish_container_name = "${local.name}-varnish"
  varnish_container_image  = "${dependency.ecr_varnish.outputs.repository_url}:latest"
  varnish_container_port   = 8081
  varnish_container_cpu    = 256
  varnish_container_memory = 512
  varnish_port_mappings = [
    {
      containerPort = 8081
      hostPort      = 8081
      protocol      = "tcp"
    }
  ]

  tags = local.common_vars.tags

}

dependency "vpc" {
  config_path = "../../../vpc"
}

dependency "alb" {
  config_path = "../../../alb/ecs-main"
}

dependency "cluster" {
  config_path = "../../cluster"
}

dependency "ecr_app" {
  config_path = "../../../ecr/test-app/app"
}

dependency "ecr_varnish" {
  config_path = "../../../ecr/test-app/varnish"
}

dependency "sg_ecs_test_app" {
  config_path = "../../../security-group/ecs/test-app"
}
