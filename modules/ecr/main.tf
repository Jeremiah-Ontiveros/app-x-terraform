resource "aws_ecr_repository" "repo" {
  name = "app-x-${var.env}"
  image_tag_mutability = var.env == "prod" ? "IMMUTABLE" : "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.repo.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description = "Keep last ${var.image_count} images"
      selection = {
        tagStatus = "any"
        countType = "imageCountMoreThan"
        countNumber = var.image_count
        }
      action = { type = "expire" }
      }]
  })
}

