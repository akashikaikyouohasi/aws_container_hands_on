##################
# ECS Service
##################
resource "aws_ecs_service" "backend" {
  # 起動タイプ
  launch_type = "FARGATE"
  # タスク定義
  task_definition = var.backend_ecs_service.task_definition.arn
  # プラットフォームのバージョン
  platform_version = "1.4.0"
  # クラスター
  cluster = var.backend_ecs_service.cluster.id
  # サービス名
  name = var.backend_ecs_service.name
  # タスクの数
  desired_count = var.backend_ecs_service.desire_count

  # デプロイメント
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # ECSで管理されたタグを有効にする
  enable_ecs_managed_tags = true

  # ネットワーク構成
  network_configuration {
    subnets         = var.backend_ecs_service.subnets
    security_groups = var.backend_ecs_service.security_groups
    # パブリックIPの自動割り当て
    assign_public_ip = false
  }
  health_check_grace_period_seconds = 120

  # ロードバランシング
  load_balancer {
    target_group_arn = var.backend_alb_target_group.arn
    container_name   = "app"
    container_port   = 80
  }


  lifecycle {
    ignore_changes = [desired_count]
  }
}

# CloudMap


# CodeDeploy