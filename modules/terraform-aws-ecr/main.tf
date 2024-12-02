locals {
  create_private_repository = var.create && var.create_repository && var.repository_type == "private"
  create_public_repository  = var.create && var.create_repository && var.repository_type == "public"
}

# Private repository
resource "aws_ecr_repository" "this" {
  count = local.create_private_repository ? 1 : 0

  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  encryption_configuration {
    encryption_type = var.repository_encryption_type
    kms_key         = var.repository_kms_key
  }

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = var.tags
}

# Private Repository Policy
resource "aws_ecr_repository_policy" "this" {
  count = local.create_private_repository && var.attach_repository_policy ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = var.create_repository_policy ? data.aws_iam_policy_document.repository[0].json : var.repository_policy
}


# Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "this" {
  count = local.create_private_repository && var.create_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this[0].name
  policy     = var.repository_lifecycle_policy
}

# Public Repository

resource "aws_ecrpublic_repository" "this" {
  count = local.create_public_repository ? 1 : 0

  repository_name = var.name

  dynamic "catalog_data" {
    for_each = length(var.public_repository_catalog_data) > 0 ? [var.public_repository_catalog_data] : []

    content {
      about_text        = try(catalog_data.value.about_text, null)
      architectures     = try(catalog_data.value.architectures, null)
      description       = try(catalog_data.value.description, null)
      logo_image_blob   = try(catalog_data.value.logo_image_blob, null)
      operating_systems = try(catalog_data.value.operating_systems, null)
      usage_text        = try(catalog_data.value.usage_text, null)
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "repository" {
  count = var.create && var.create_repository && var.create_repository_policy ? 1 : 0

  dynamic "statement" {
    for_each = var.repository_type == "public" ? [1] : []

    content {
      sid = "PublicReadOnly"

      principals {
        type = "AWS"
        identifiers = coalescelist(
          var.repository_read_access_arns,
          ["*"],
        )
      }

      actions = [
        "ecr-public:BatchGetImage",
        "ecr-public:GetDownloadUrlForLayer",
      ]
    }
  }
}

# Public Repository Policy
resource "aws_ecrpublic_repository_policy" "example" {
  count = local.create_public_repository ? 1 : 0

  repository_name = aws_ecrpublic_repository.this[0].repository_name
  policy          = var.create_repository_policy ? data.aws_iam_policy_document.repository[0].json : var.repository_policy
}

# Registry Policy
resource "aws_ecr_registry_policy" "this" {
  count = var.create && var.create_registry_policy ? 1 : 0

  policy = var.registry_policy
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = var.repository_lifecycle_policy
}
