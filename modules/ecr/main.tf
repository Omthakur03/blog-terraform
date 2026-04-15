resource "aws_ecr_repository" "microservices" {
    for_each = toset(var.service_names)

    name = "${var.project_name}-${var.env_name}-${each.value}-repo"
    image_tag_mutability = "MUTABLE"

    force_delete         = true

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "${var.project_name}-${var.env_name}-${each.value}-repo"
    }

}


resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
    for_each = aws_ecr_repository.microservices

    repository = each.value.name

    policy = jsonencode({
        rules = [{
            rulePriority = 1
            description = "Keep Last 5 images"
            selection = {
                tagStatus = "any"
                countType = "imageCountMoreThan"
                countNumber = 5
            }
            action = {
                type = "expire"
            }
        }]
    })

}

output "respository_urls" {
    description = "Map of service names to their ECR URLs"
    value = {
        for k, v in aws_ecr_repository.microservices : k => v.repository_url
    }
}