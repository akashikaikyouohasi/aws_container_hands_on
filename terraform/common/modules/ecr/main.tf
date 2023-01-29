resource "aws_ecr_repository" "ecr" {
  for_each = var.ecr

  name                 = each.value.name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
    #kms_key = null #if not specified, uses the default AWS managed key for ECR
  }

}

# ライフサイクルポリシー
resource "aws_ecr_lifecycle_policy" "foopolicy" {
  for_each   = var.ecr
  repository = aws_ecr_repository.ecr[each.key].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1000,
            "description": "古い世代のイメージを削除",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}