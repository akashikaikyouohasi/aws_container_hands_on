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
      ### スタンダード ###
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
      ### ヘルスチェック ###

      ### 環境 ###
      # CPUユニット数
      cpu = var.ecs_backend.task_definition.cpu
      #基本
      essential = true
      # 環境変数
      secrets = [
        {
          name : "DB_HOST",
          valueFrom : "${var.ecs_backend.task_definition.secrets_manager}:host::"
        },
        {
          name : "DB_NAME",
          valueFrom : "${var.ecs_backend.task_definition.secrets_manager}:dbname::"
        },
        {
          name : "DB_USERNAME",
          valueFrom : "${var.ecs_backend.task_definition.secrets_manager}:username::"
        },
        {
          name : "DB_PASSWORD",
          valueFrom : "${var.ecs_backend.task_definition.secrets_manager}:password::"
        }
      ]

      ### コンテナタイムアウト ###

      ### ネットワーク設定 ###

      ### ストレージとログ ###
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

      ### リソースの制限 ###

      ### DOCKERラベル ###

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
    name  = "containerInsights"
    value = "enabled"
  }

}