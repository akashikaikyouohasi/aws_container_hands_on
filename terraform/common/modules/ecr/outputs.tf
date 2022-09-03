output "ecr_repositories" {
  value = { for value in aws_ecr_repository.ecr : value.name => value.arn }
}
output "ecr_repositories_uri" {
  value = { for value in aws_ecr_repository.ecr : value.name => value.repository_url }
}