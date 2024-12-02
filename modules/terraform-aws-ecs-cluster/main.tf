resource "aws_ecs_cluster" "this" {
  count = var.create_ecs ? 1 : 0

  name = var.name
  //capacity_providers = var.capacity_providers
  setting {
    name = "containerInsights"
    #Cloudwatch Container Insights provide more metrics and logs for container based applications and micro services.
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this[0].name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    iterator = strategy

    content {
      capacity_provider = strategy.value["capacity_provider"]
      weight            = lookup(strategy.value, "weight", null)
      base              = lookup(strategy.value, "base", null)
    }
  }
}
