output "repository_urls" {
  description = "ECR repository URLs"

  value = {
    for key, repo in aws_ecr_repository.this :
    key => repo.repository_url
  }
}

output "repository_arns" {
  description = "ECR repository ARNs"

  value = {
    for key, repo in aws_ecr_repository.this :
    key => repo.arn
  }
}

output "repository_names" {
  description = "ECR repository names"

  value = {
    for key, repo in aws_ecr_repository.this :
    key => repo.name
  }
}

output "registry_ids" {
  description = "ECR registry IDs"

  value = {
    for key, repo in aws_ecr_repository.this :
    key => repo.registry_id
  }
}