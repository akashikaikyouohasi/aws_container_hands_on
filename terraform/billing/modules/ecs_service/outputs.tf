output "ecs_task_definition_frontend" {
  value = aws_ecs_task_definition.frontend
}

output "ecs_backend_codedeploy_application_name" {
  value = aws_codedeploy_app.backend.name
}
output "ecs_backend_codedeploy_deploy_group_name" {
  value = aws_codedeploy_deployment_group.backend.app_name
}