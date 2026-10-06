resource "aws_ecr_repository" "backend" {
  name                 = "backend-api"
  image_tag_mutability = "IMMUTABLE"                   # a tag can never be overwritten -> unique tag per build
  image_scanning_configuration { scan_on_push = true } # basic CVE scan on every push
}
resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name
  policy = jsonencode({ rules = [{
    rulePriority = 1, description = "keep last 20 images",
    selection    = { tagStatus = "any", countType = "imageCountMoreThan", countNumber = 20 },
  action = { type = "expire" } }] })
}
