output "repository_name" {
  description = "Name of the repository"
  value       = try(aws_ecr_repository.this[0].name, aws_ecrpublic_repository.this[0].id, null)
}

output "repository_registry_id" {
  description = "The registry ID where the repository was created"
  value       = try(aws_ecr_repository.this[0].registry_id, aws_ecrpublic_repository.this[0].registry_id, null)
}
