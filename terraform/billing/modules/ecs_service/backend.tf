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

  # サービスの検出
  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  # 新しいデプロイの強制
  force_new_deployment = false

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

##################
# Cloud Map
##################
resource "aws_service_discovery_service" "backend" {
  name = var.backend_ecs_service.name

  dns_config {
    # 名前空間ID
    namespace_id = var.backend_ecs_service.namespace_id

    # DNSルーティングポリシー
    routing_policy = "MULTIVALUE" #複数値解答ルーティング
    dns_records {
      ttl  = 60
      type = "A"
    }
  }

  # カスタムヘルスチェックの設定
  health_check_custom_config {
    # 失敗しきい値
    failure_threshold = 1
  }
}

##################
# AutoSacling
##################
resource "aws_appautoscaling_target" "appautoscaling_ecs_target" {
  service_namespace = "ecs"

  # ECSサービス名
  resource_id        = "service/${var.backend_ecs_service.cluster.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  # 最小数
  min_capacity = 2
  # 最大数
  max_capacity = 4
}

resource "aws_appautoscaling_policy" "appautoscaling_scale_up" {
  name              = "sbcntr-ecs-scalingPolicy"
  service_namespace = "ecs"

  # ECSサービス名
  resource_id        = "service/${var.backend_ecs_service.cluster.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  # スケーリングのポリシータイプ
  policy_type = "TargetTrackingScaling"
  target_tracking_scaling_policy_configuration {
    # ECSのサービスメトリクス
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    # ターゲット値
    target_value = 50
    # スケールアウトクールダウン期間
    scale_out_cooldown = 300
    # スケールインクールダウン期間
    scale_in_cooldown = 300
    # スケールインの無効化
    disable_scale_in = false
  }
}