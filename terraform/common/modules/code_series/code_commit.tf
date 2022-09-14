# Code Commit
resource "aws_codecommit_repository" "backend" {
  repository_name = var.code_commit.backend.repository_name
  description     = "Repository for sbcntr backend application"
}
