#####################
# IAM
#####################
### Policy ###
# AWS管理ポリシー:ECSタスク実行
data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets Manager読み込み
resource "aws_iam_policy" "secrets_manager" {
  name   = "sbcntr-GettingSecretsPolicy"
  policy = data.aws_iam_policy_document.secrets_manager.json
}
data "aws_iam_policy_document" "secrets_manager" {
  statement {
    sid    = "GetSecretForECS"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "*"
    ]
  }
}

# S3バケットとログ出力
resource "aws_iam_policy" "s3_kms_logs" {
  name   = "sbcntr-AccessingLogDestination"
  policy = data.aws_iam_policy_document.s3_kms_logs.json
}
data "aws_iam_policy_document" "s3_kms_logs" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.log_s3_bucket_name}",
      "arn:aws:s3:::${var.log_s3_bucket_name}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      "*"
    ]
  }
    statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}


### IAM Role ###
data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = var.ecs_backend.task_definition.ecs_task_iam_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_policy_attachment" "ecs_task" {
  name       = var.ecs_backend.task_definition.ecs_task_iam_name
  roles      = [aws_iam_role.ecs_task.name]
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}
resource "aws_iam_policy_attachment" "secrets_manager" {
  name       = var.ecs_backend.task_definition.ecs_task_iam_name
  roles      = [aws_iam_role.ecs_task.name]
  policy_arn = aws_iam_policy.secrets_manager.arn
}
resource "aws_iam_policy_attachment" "s3_kms_logs" {
  name       = var.ecs_backend.task_definition.ecs_task_iam_name
  roles      = [aws_iam_role.ecs_task.name]
  policy_arn = aws_iam_policy.s3_kms_logs.arn
}