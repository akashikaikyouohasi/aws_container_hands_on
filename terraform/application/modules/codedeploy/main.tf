#####################
# IAM
#####################
# AWS管理ポリシー取得
data "aws_iam_policy" "AWSCodeDeployRoleForECS" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# IAM Role
data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "codedeploy" {
  name               = var.iam.name
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "codedeploy" {
  name       = var.iam.name
  roles      = [aws_iam_role.codedeploy.name]
  policy_arn = data.aws_iam_policy.AWSCodeDeployRoleForECS.arn
}

