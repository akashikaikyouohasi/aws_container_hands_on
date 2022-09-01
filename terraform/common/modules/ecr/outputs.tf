output "ecr_repositories" {
  value = { for value in aws_ecr_repository.ecr : value.name => value.arn }
}