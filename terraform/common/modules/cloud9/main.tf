# cloud9 作成
resource "aws_cloud9_environment_ec2" "main" {
  name        = var.cloud9.name
  description = var.cloud9.description

  connection_type = var.cloud9.connection_type
  instance_type   = var.cloud9.instance_type
  image_id        = "amazonlinux-2-x86_64"

  automatic_stop_time_minutes = 30
  subnet_id                   = var.public_subnets[var.cloud9.subnet_id]

  # Terraform実行ユーザーとコンソールユーザーが異なるため設定
  owner_arn = var.cloud9.owner_arn
}

# セキュリティグループ割り当て
resource "aws_network_interface_sg_attachment" "sg" {
  security_group_id    = var.sg[var.cloud9.security_group]
  network_interface_id = data.aws_instance.cloud9_instance.network_interface_id
}

# Cloud9のインスタンスの情報を取得
data "aws_instance" "cloud9_instance" {
  filter {
    name   = "tag:aws:cloud9:environment"
    values = [aws_cloud9_environment_ec2.main.id]
  }
}

output "cloud9_values" {
  value = data.aws_instance.cloud9_instance
}

### IAM policy作成 ###
# ECR用
# 参考：https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html#security_iam_id-based-policy-examples-access-one-bucket
data "aws_iam_policy_document" "cloud9" {
  statement {
    sid    = "ListImagesInRepository"
    effect = "Allow"
    actions = [
      "ecr:ListImages"
    ]
    resources = [
      for k, v in var.ecr_repositories : v
    ]
  }
  statement {
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "ManageRepositoryContents"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = [
      for k, v in var.ecr_repositories : v
    ]
  }
}
resource "aws_iam_policy" "cloud9" {
  name        = "sbcntr-AccessingECRRepositoryPolicy"
  description = "Policy to access ECR repo from Cloud9 instance"
  policy      = data.aws_iam_policy_document.cloud9.json
}

# CodeCommit用
data "aws_iam_policy_document" "code_commit" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:BatchGet*",
      "codecommit:BatchDescribe*",
      "codecommit:Describe*",
      "codecommit:Get*",
      "codecommit:List*",
      "codecommit:Merge*",
      "codecommit:Put*",
      "codecommit:Post*",
      "codecommit:Update*",
      "codecommit:GitPull",
      "codecommit:GitPush"
    ]
    resources = [
      var.code_commit_backend.arn
    ]
  }
}
resource "aws_iam_policy" "code_commit" {
  name        = "sbcntr-AccessingCodeCommitPolicy"
  policy      = data.aws_iam_policy_document.code_commit.json
}

# IAM Role
data "aws_iam_policy_document" "cloud9_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloud9" {
  name               = "sbcntr-cloud9-role"
  assume_role_policy = data.aws_iam_policy_document.cloud9_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "cloud9" {
  name       = "cloud9_attachment"
  roles      = [aws_iam_role.cloud9.name]
  policy_arn = aws_iam_policy.cloud9.arn
}
resource "aws_iam_policy_attachment" "code_commit" {
  name       = "code_commit_attachment"
  roles      = [aws_iam_role.cloud9.name]
  policy_arn = aws_iam_policy.code_commit.arn
}

# EC2用
resource "aws_iam_instance_profile" "cloud9" {
  name = "sbcntr-cloud9-role"
  role = aws_iam_role.cloud9.name
}
# IAMロールをCloud9にアタッチできそうにないので、手動で付ける
