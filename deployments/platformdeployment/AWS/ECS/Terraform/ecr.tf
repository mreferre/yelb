#If you want to use ECR repository instead docker repository you can uncomment this file 
#Also make sure to change image url in ecs.tf accordingly
/*
resource "aws_ecr_repository" "app-ui" {
  name                 = var.app_ui_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app-server" {
  name                 = var.app_server_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app-cache" {
  name                 = var.app_cache_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app-db" {
  name                 = var.app_db_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "app-ui-repo-policy" {
  repository = aws_ecr_repository.app-ui.name
  policy     = var.repository_policy
}

resource "aws_ecr_repository_policy" "app-server-repo-policy" {
  repository = aws_ecr_repository.app-server.name
  policy     = var.repository_policy
}

resource "aws_ecr_repository_policy" "app-cache-repo-policy" {
  repository = aws_ecr_repository.app-cache.name
  policy     = var.repository_policy
}

resource "aws_ecr_repository_policy" "app-db-repo-policy" {
  repository = aws_ecr_repository.app-db.name
  policy     = var.repository_policy
}
*/