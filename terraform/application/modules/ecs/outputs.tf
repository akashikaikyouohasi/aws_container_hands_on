output "ecs_task_definition_backend" {
  value = aws_ecs_task_definition.backend
}
output "ecs_cluster_backend" {
  value = aws_ecs_cluster.backend
}
output "ecs_cluster_frontend" {
  value = aws_ecs_cluster.frontend
}

output "ecs_task" {
  value = aws_iam_role.ecs_task
}
