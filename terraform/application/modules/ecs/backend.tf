#####################
# IAM
#####################
# AWS管理ポリシー取得
data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role
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

#####################
# ECS Task
#####################
resource "aws_ecs_task_definition" "backend" {
  # タスク定義名
  family                   = var.ecs_backend.task_definition.name
  requires_compatibilities = ["FARGATE"]
  # タスクロール
  task_role_arn = aws_iam_role.ecs_task.arn
  # ネットワークモード
  network_mode = "awsvpc"

  # タスク実行ロール
  execution_role_arn = aws_iam_role.ecs_task.arn

  # タスクサイズ
  memory = 1024
  cpu    = 512

  #https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html を元に設定
  container_definitions = jsonencode([
    {
      name  = var.ecs_backend.task_definition.container_name
      image = "${var.ecs_backend.task_definition.repository_url}:${var.ecs_backend.task_definition.image_tag}"
      # ソフト制限メモリ制限
      memoryReservation = var.ecs_backend.task_definition.memory_soft
      # ポートマッピング
      portMappings = [
        {
          containerPort = 80
        }
      ]
      # CPUユニット数
      cpu = var.ecs_backend.task_definition.cpu
      #基本
      essential = true
      # 読み取り専用ルートファイルシステム
      readonlyRootFilesystem = true

      # ログ設定
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : var.ecs_backend.task_definition.awslogs_group
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

#####################
# CloudWatch Logs
#####################
resource "aws_cloudwatch_log_group" "backend" {
  name              = var.ecs_backend.task_definition.awslogs_group
  retention_in_days = 30
}

#####################
# ECS Cluster
#####################
resource "aws_ecs_cluster" "backend" {
  name = var.ecs_backend.cluster.name
  setting {
    name = "containerInsights"
    value = "enabled"
  }
  
}