#####################
# ECS Task
#####################
resource "aws_ecs_task_definition" "frontend" {
  # タスク定義名
  family                   = var.ecs_frontend.task_definition.name
  requires_compatibilities = ["FARGATE"]
  # タスクロール
  task_role_arn = var.ecs_task_role
  # ネットワークモード
  network_mode = "awsvpc"

  # タスク実行ロール
  execution_role_arn = var.ecs_task_role

  # タスクサイズ
  memory = 1024
  cpu    = 512

  #https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html を元に設定
  container_definitions = jsonencode([
    {
      name  = var.ecs_frontend.task_definition.container_name
      image = "${var.ecs_frontend.task_definition.repository_url}:${var.ecs_frontend.task_definition.image_tag}"
      # ソフト制限メモリ制限
      memoryReservation = var.ecs_frontend.task_definition.memory_soft
      # ポートマッピング
      portMappings = [
        {
          containerPort = 80
        }
      ]
      # CPUユニット数
      cpu = var.ecs_frontend.task_definition.cpu
      #基本
      essential = true

      environment = [
        {
          name  = "SESSION_SECRET_KEY",
          value = "41b678c65b37bf99c37bcab522802760"
        },
        {
          name  = "APP_SERVICE_HOST",
          value = "http://${var.ecs_frontend.task_definition.backendhost}"
        },
        {
          name  = "NOTIF_SERVICE_HOST",
          value = "http://${var.ecs_frontend.task_definition.backendhost}"
        }
      ]
      secrets = [
        {
          name : "DB_HOST",
          valueFrom : "${var.ecs_frontend.task_definition.secrets_manager}:host::"
        },
        {
          name : "DB_NAME",
          valueFrom : "${var.ecs_frontend.task_definition.secrets_manager}:dbname::"
        },
        {
          name : "DB_USERNAME",
          valueFrom : "${var.ecs_frontend.task_definition.secrets_manager}:username::"
        },
        {
          name : "DB_PASSWORD",
          valueFrom : "${var.ecs_frontend.task_definition.secrets_manager}:password::"
        }
      ]

      # 読み取り専用ルートファイルシステム
      readonlyRootFilesystem = true

      # ログ設定
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : var.ecs_frontend.task_definition.awslogs_group
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

#####################
# CloudWatch Logs
#####################
resource "aws_cloudwatch_log_group" "frontend" {
  name              = var.ecs_frontend.task_definition.awslogs_group
  retention_in_days = 14
}



##################
# ECS Service
##################
resource "aws_ecs_service" "frontend" {
  # 起動タイプ
  launch_type = "FARGATE"
  # タスク定義
  task_definition = var.frontend_ecs_service.task_definition.arn
  # プラットフォームのバージョン
  platform_version = "1.4.0"
  # クラスター
  cluster = var.frontend_ecs_service.cluster.id
  # サービス名
  name = var.frontend_ecs_service.name
  # タスクの数
  desired_count = var.frontend_ecs_service.desire_count

  # デプロイメント
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # ECSで管理されたタグを有効にする
  enable_ecs_managed_tags = true

  # ネットワーク構成
  network_configuration {
    subnets         = var.frontend_ecs_service.subnets
    security_groups = var.frontend_ecs_service.security_groups
    # パブリックIPの自動割り当て
    assign_public_ip = false
  }
  health_check_grace_period_seconds = 120

  # ロードバランシング
  load_balancer {
    target_group_arn = var.frontend_alb_target_group.arn
    container_name   = "app"
    container_port   = 80
  }

  # サービスの検出
  service_registries {
    registry_arn = aws_service_discovery_service.frontend.arn
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

##################
# CodeDeploy
##################
resource "aws_codedeploy_app" "frontend" {
  compute_platform = "ECS"
  name             = var.frontend_ecs_service.codedeploy_name
}

resource "aws_codedeploy_deployment_group" "frontend" {
  app_name = aws_codedeploy_app.frontend.name
  # デプロイグループ名
  deployment_group_name = var.frontend_ecs_service.codedeploy_name
  # サービスロール
  service_role_arn = var.frontend_ecs_service.codedeploy_role.arn
  # 環境設定
  ecs_service {
    cluster_name = var.frontend_ecs_service.cluster.name
    service_name = aws_ecs_service.frontend.name
  }
  # Load balancer
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.frontend_alb_lister_blue.arn]
      }
      test_traffic_route {
        listener_arns = [var.frontend_alb_lister_green.arn]
      }
      target_group {
        name = var.frontend_alb_target_group.name
      }
      target_group {
        name = var.frontend_alb_target_group_green.name
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
      wait_time_in_minutes = var.frontend_ecs_service.blue_green_deployment_wait_time_in_minutes
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.frontend_ecs_service.termination_wait_time_in_minutes
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
resource "aws_service_discovery_service" "frontend" {
  name = var.frontend_ecs_service.name

  dns_config {
    # 名前空間ID
    namespace_id = var.frontend_ecs_service.namespace_id

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