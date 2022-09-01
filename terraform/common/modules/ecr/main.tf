resource "aws_ecr_repository" "ecr" {
  for_each = var.ecr

  name                 = each.value.name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
    #kms_key = null #if not specified, uses the default AWS managed key for ECR
  }

}