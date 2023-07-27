# Create ECR repository
resource "aws_ecr_repository" "prophius_ecr" {
  name = var.ecr
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "ecrlifecycle_policy" {
  repository = aws_ecr_repository.prophius_ecr.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire images older than 30 days",
        selection    = {
          tagStatus = "untagged",
          countType = "sinceImagePushed",
          countUnit = "days",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}