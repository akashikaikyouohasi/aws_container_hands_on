#####################
# CloudWatch Logs group
#####################
resource "aws_cloudwatch_log_group" "logs" {
  name = "/aws/ecs/sbcntr-firelens-container"
  retention_in_days = 14
}

