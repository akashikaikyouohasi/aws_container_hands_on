#####################
# CodeBuild
#####################
resource "aws_codebuild_project" "code_build_backend" {
  ### プロジェクトの設定 ###
  # プロジェクト名
  name = var.code_build.backend.name
  # ビルドバッチ
  badge_enabled = true
  # 同時ビルド制限の有効化
  #concurrent_build_limit = 1

  ### ソース ###
  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.backend.clone_url_http
  }
  # リファレンスタイプ：https://docs.aws.amazon.com/ja_jp/codebuild/latest/userguide/sample-source-version.html
  source_version = "refs/heads/main"

  ### 環境 ### Buildspec ###
  environment {
    # 環境イメージ
    type  = "LINUX_CONTAINER"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    # 特権付与
    privileged_mode = true


    # 証明書
    # コンピューティング
    compute_type = "BUILD_GENERAL1_SMALL"
  }
  # サービスロール
  service_role = aws_iam_role.code_build.arn
  # タイムアウト
  build_timeout  = "60"  #minutes
  queued_timeout = "480" #minutes


  ### バッチ設定 ###
  #build_batch_config {
  #}

  ### アーティファクト ###
  artifacts {
    # タイプ
    type = "NO_ARTIFACTS"
  }
  cache {
    # キャッシュタイプ
    type = "LOCAL"
    # オプション
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  ### ログ ###
  logs_config {
    cloudwatch_logs {
      # グループ名
      group_name = ""
      # ストリーム名
      stream_name = ""
    }
    s3_logs {
      # S3ログ - オプショナル
      status = "DISABLED"
    }
  }
}

#####################
# CodeBuild用のIAM
#####################
# IAM plicy for CodeBuild
data "aws_iam_policy_document" "code_build" {
  statement {
    sid    = "CloudWatchLogsPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "S3GetObjectPolicy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "S3PutObjectPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "ECRPullPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "ECRAuthPolicy"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "S3BucketIdentity"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "*"
    ]
  }

}
resource "aws_iam_policy" "code_build" {
  name   = "CodeBuildServiceRolePolicy"
  policy = data.aws_iam_policy_document.code_build.json
}

# IAM plicy for CodeBuild to ECR
data "aws_iam_policy_document" "code_build_ecr" {
  statement {
    sid    = "ListImagesInRepository"
    effect = "Allow"
    actions = [
      "ecr:ListImages"
    ]
    resources = [
      "*"
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
      "*"
    ]
  }
}
resource "aws_iam_policy" "code_build_ecr" {
  name   = "CodeBuild-AccessingECRRepositoryPolicy"
  policy = data.aws_iam_policy_document.code_build_ecr.json
}


# IAM Role
data "aws_iam_policy_document" "code_build_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "code_build" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.code_build_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "code_build" {
  name       = "code_build_attachment"
  roles      = [aws_iam_role.code_build.name]
  policy_arn = aws_iam_policy.code_build.arn
}
resource "aws_iam_policy_attachment" "code_build_ecr" {
  name       = "code_build_attachment"
  roles      = [aws_iam_role.code_build.name]
  policy_arn = aws_iam_policy.code_build_ecr.arn
}
