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