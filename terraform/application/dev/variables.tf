#####################
# IAM
#####################
locals {
  iam = {
    name = "ecsCodeDeployRole"
  }
}

#####################
# ECS
#####################
locals {
  ecs_backend = {
    task_definition = {
      name           = "sbcntr-ecs-backend-def"
      container_name = "app"
      memory_soft    = 512
      cpu            = 256

      repository_url = data.terraform_remote_state.common.outputs.ecr.ecr_repositories_uri["sbcntr-backend"]
      image_tag      = "v1"

      awslogs_group     = "/dev-ecs-handson/sbcntr-backend-def"
      ecs_task_iam_name = "EcsTaskRole"
    }
    cluster = {
      name = "sbcntr-ecs-backend-cluster"

    }

  }
  ecs_frontend = {
    # billingで作成するため、ここでは利用していない
    # task_definition = {
    #   name           = "sbcntr-ecs-frontend-def"
    #   container_name = "app"
    #   memory_soft    = 512
    #   cpu            = 256

    #   repository_url = data.terraform_remote_state.common.outputs.ecr.ecr_repositories_uri["sbcntr-frontend"]
    #   image_tag      = "v1"

    #   backendhost = ""

    #   awslogs_group     = "/dev-ecs-handson/sbcntr-frontend-def"
    #   ecs_task_iam_name = "EcsTaskRole"
    # }
    cluster = {
      name = "sbcntr-ecs-frontend-cluster"

    }
  }
}