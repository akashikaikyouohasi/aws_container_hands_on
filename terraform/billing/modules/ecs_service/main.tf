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

##################
# CodeDeploy
##################
resource "aws_codedeploy_app" "backend" {
  compute_platform = "ECS"
  name             = var.backend_ecs_service.codedeploy_name
}

resource "aws_codedeploy_deployment_group" "backend" {
  app_name = aws_codedeploy_app.backend.name
  # デプロイグループ名
  deployment_group_name = var.backend_ecs_service.codedeploy_name
  # サービスロール
  service_role_arn = var.backend_ecs_service.codedeploy_role.arn
  # 環境設定
  ecs_service {
    cluster_name = var.backend_ecs_service.cluster.name
    service_name = aws_ecs_service.backend.name
  }
  # Load balancer
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.backend_alb_lister_blue.arn]
      }
      test_traffic_route {
        listener_arns = [var.backend_alb_lister_green.arn]
      }
      target_group {
        name = var.backend_alb_target_group.name
      }
      target_group {
        name = var.backend_alb_target_group_green.name
      }
    }
  }
  # デプロイ設定
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = var.backend_ecs_service.blue_green_deployment_wait_time_in_minutes
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.backend_ecs_service.termination_wait_time_in_minutes
    }
  }

  # ロールバック
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}