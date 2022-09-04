# #####################
# # ECS Task
# #####################
# billingで作成するため、ここでは利用していない
# resource "aws_ecs_task_definition" "frontend" {
#   # タスク定義名
#   family                   = var.ecs_frontend.task_definition.name
#   requires_compatibilities = ["FARGATE"]
#   # タスクロール
#   task_role_arn = aws_iam_role.ecs_task.arn
#   # ネットワークモード
#   network_mode = "awsvpc"

#   # タスク実行ロール
#   execution_role_arn = aws_iam_role.ecs_task.arn

#   # タスクサイズ
#   memory = 1024
#   cpu    = 512

#   #https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_ContainerDefinition.html を元に設定
#   container_definitions = jsonencode([
#     {
#       name  = var.ecs_frontend.task_definition.container_name
#       image = "${var.ecs_frontend.task_definition.repository_url}:${var.ecs_frontend.task_definition.image_tag}"
#       # ソフト制限メモリ制限
#       memoryReservation = var.ecs_frontend.task_definition.memory_soft
#       # ポートマッピング
#       portMappings = [
#         {
#           containerPort = 80
#         }
#       ]
#       # CPUユニット数
#       cpu = var.ecs_frontend.task_definition.cpu
#       #基本
#       essential = true

#       environment = [
#         { 
#             name = "SESSION_SECRET_KEY",
#             value = "41b678c65b37bf99c37bcab522802760"
#         },
#         { 
#             name = "APP_SERVICE_HOST",
#             value = "http://${var.ecs_frontend.backendhost}"
#         },
#         { 
#             name = "NOTIF_SERVICE_HOST",
#             value = "http://${var.ecs_frontend.backendhost}"
#         }
#       ]

#       # 読み取り専用ルートファイルシステム
#       readonlyRootFilesystem = true

#       # ログ設定
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-region : "ap-northeast-1"
#           awslogs-group : var.ecs_frontend.task_definition.awslogs_group
#           awslogs-stream-prefix : "ecs"
#         }
#       }
#     }
#   ])
# }

# #####################
# # CloudWatch Logs
# #####################
# resource "aws_cloudwatch_log_group" "frontend" {
#   name              = var.ecs_frontend.task_definition.awslogs_group
#   retention_in_days = 14
# }

#####################
# ECS Cluster
#####################
resource "aws_ecs_cluster" "frontend" {
  name = var.ecs_frontend.cluster.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}