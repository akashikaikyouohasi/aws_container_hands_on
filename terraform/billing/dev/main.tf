#####################
# Common
#####################
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = "tfstate-terraform-20211204"
    key    = "dev-ecs-handson/dev/common.tfstate"
    region = "ap-northeast-1"
  }
}

#####################
# Application
#####################
data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "tfstate-terraform-20211204"
    key    = "dev-ecs-handson/dev/application.tfstate"
    region = "ap-northeast-1"
  }
}

##################
# NWリソース設定
##################

module "endpoints" {
  source = "../modules/endpoints"

  vpc_id = data.aws_vpc.vpc.id

  interface_endpoints = local.interface_endpoints
}

### data
# vpc id
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}
# subnet
data "aws_subnets" "subnets" {
  for_each = local.sbunet

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = {
    Name = each.value
  }
}
# sg
data "aws_security_groups" "security_groups" {
  for_each = local.sg

  filter {
    name   = "group-name"
    values = [each.value]
  }
}

##################
# ALB
##################
module "alb" {
  source = "../modules/alb"

  vpc_id = data.aws_vpc.vpc.id

  internal_albs                = local.internal_albs
  target_groups               = local.target_groups
  listener_internal_alb_green = local.listener_internal_alb_green

  frontend_albs                = local.frontend_albs
  target_group_frontend               = local.target_group_frontend
  listener_frontend_alb_green = local.listener_frontend_alb_green
}

output "alb" {
  value = module.alb
}

##################
# ECS Service
##################
module "ecs_service" {
  source = "../modules/ecs_service"

  backend_ecs_service            = local.backend_ecs_service
  backend_alb_target_group       = module.alb.internal_alb_target_group["sbcntr-tg-sbcntrdemo-blue"]
  backend_alb_target_group_green = module.alb.internal_alb_target_group["sbcntr-tg-sbcntrdemo-green"]
  backend_alb_lister_blue        = module.alb.internal_alb_listener_blue
  backend_alb_lister_green       = module.alb.internal_alb_listener_green

  frontend_ecs_service            = local.frontend_ecs_service
  frontend_alb_target_group       = module.alb.frontend_alb_target_group["sbcntr-tg-frontend-blue"]
  frontend_alb_target_group_green = module.alb.frontend_alb_target_group["sbcntr-tg-frontend-green"]
  frontend_alb_lister_blue        = module.alb.frontend_alb_listener_blue
  frontend_alb_lister_green       = module.alb.frontend_alb_listener_green

  ecs_task_role = data.terraform_remote_state.application.outputs.ecs.ecs_task.arn
  ecs_frontend  = local.ecs_frontend
}

output "ecs_service" {
  value = module.ecs_service
}
