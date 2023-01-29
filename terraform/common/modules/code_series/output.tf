output "code_commit_backend" {
  value = aws_codecommit_repository.backend
}

output "code_commit_backend_reposiroty_name" {
  value = aws_codecommit_repository.backend.repository_name
}
output "code_build_backend_project_name" {
  value = aws_codebuild_project.code_build_backend.name
}
