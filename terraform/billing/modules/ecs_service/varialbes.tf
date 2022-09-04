variable "backend_ecs_service" {}

variable "backend_alb_target_group" {}
variable "backend_alb_target_group_green" {}
variable "backend_alb_lister_blue" {}
variable "backend_alb_lister_green" {}

variable "frontend_ecs_service" {}

variable "frontend_alb_target_group" {}
variable "frontend_alb_target_group_green" {}
variable "frontend_alb_lister_blue" {}
variable "frontend_alb_lister_green" {}

variable "ecs_task_role" {}
variable "ecs_frontend" {}
