resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
  }

  tags = merge(
    var.common_tags,
    {
      Name = each.value.name
    }
  )
}

# Lifecycle policy to keep the repository clean
resource "aws_ecr_lifecycle_policy" "this" {
  for_each = {
    for key, repo in var.repositories :
    key => repo
    if repo.enable_lifecycle_policy
  }

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Keep last ${each.value.keep_image_count} images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = each.value.keep_image_count
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}