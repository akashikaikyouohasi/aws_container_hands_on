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

##################
# CodeDeploy
##################
module "codedeploy" {
  source = "../modules/codedeploy"

  iam = local.iam
}
output "codedeploy" {
  value = module.codedeploy
}

##################
# ECS
##################
module "ecs" {
  source = "../modules/ecs"

  ecs_backend  = local.ecs_backend
  ecs_frontend = local.ecs_frontend
}
output "ecs" {
  value = module.ecs
}

##################
# Aurora
##################
module "aurora" {
  source = "../modules/aurora"

  aurora = local.aurora
}
output "aurora" {
  value     = module.aurora
  sensitive = true
}
