#####################
# data
#####################
locals {
  # subnetとSGの名前は、引数になります。
  sbunet = {
    ecr_api_endpoint         = "sbcntr-subnet-private-egress*"
    ecr_dkr_endpoint         = "sbcntr-subnet-private-egress*"
    cloudwatch_logs_endpoint = "sbcntr-subnet-private-egress*"
    internal_alb             = "sbcntr-subnet-private-container*"
  }
  sg = {
    ecr_api_endpoint         = "egress"
    ecr_dkr_endpoint         = "egress"
    cloudwatch_logs_endpoint = "egress"
    internal_alb             = "internal_alb"
  }
}

#####################
# NWリソース
#####################
locals {
  vpc_name = "sbcntrVpc"
}

locals {
  interface_endpoints = {
    ecr_api_endpoint = {
      name               = "sbcntr-vpce-ecr-api"
      service_name       = "com.amazonaws.ap-northeast-1.ecr.api"
      subnet_ids         = data.aws_subnets.subnets["ecr_api_endpoint"].ids
      security_group_ids = data.aws_security_groups.security_groups["ecr_api_endpoint"].ids
    }
    ecr_dkr_endpoint = {
      name               = "sbcntr-vpce-ecr-dkr"
      service_name       = "com.amazonaws.ap-northeast-1.ecr.dkr"
      subnet_ids         = data.aws_subnets.subnets["ecr_dkr_endpoint"].ids
      security_group_ids = data.aws_security_groups.security_groups["ecr_dkr_endpoint"].ids
    }
    cloudwatch_logs_endpoint = {
      name               = "sbcntr-vpce-logs"
      service_name       = "com.amazonaws.ap-northeast-1.logs"
      subnet_ids         = data.aws_subnets.subnets["cloudwatch_logs_endpoint"].ids
      security_group_ids = data.aws_security_groups.security_groups["cloudwatch_logs_endpoint"].ids
    }
    secretmanager_endpoint = {
      name         = "sbcntr-vpce-secrets"
      service_name = "com.amazonaws.ap-northeast-1.secretsmanager"
      subnet_ids = [
        data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-egress-1a"],
        data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-egress-1c"]
      ]
      security_group_ids = [
        data.terraform_remote_state.common.outputs.vpc.sg["egress"]
      ]
    }
  }
}

#####################
# Internal ALB
#####################
locals {
  internal_albs = {
    internal_alb = {
      name            = "sbcntr-alb-internal"
      ip_address_type = "ipv4"
      subnets         = data.aws_subnets.subnets["internal_alb"].ids
      security_groups = data.aws_security_groups.security_groups["internal_alb"].ids
      lister = {
        port       = "80"
        protocol   = "HTTP"
        default_tg = "internal_alb_blue"
      }
    }
  }
  target_groups = {
    internal_alb_blue = {
      lb           = "internal_alb"
      name         = "sbcntr-tg-sbcntrdemo-blue"
      health_check = "/healthcheck"
      port         = "80"
    }
    internal_alb_green = {
      lb           = "internal_alb"
      name         = "sbcntr-tg-sbcntrdemo-green"
      health_check = "/healthcheck"
      port         = "80"
    }
  }
  listener_internal_alb_green = {
    lb       = "internal_alb"
    port     = "10080"
    protocol = "HTTP"
    tg       = "internal_alb_green"
  }
}
#####################
# Frontend ALB
#####################
locals {
  frontend_albs = {
    frontend_alb = {
      name            = "sbcntr-alb-ingress-frontend"
      ip_address_type = "ipv4"
      subnets = [
        data.terraform_remote_state.common.outputs.vpc.public_subnets["sbcntr-subnet-public-ingress-1a"],
        data.terraform_remote_state.common.outputs.vpc.public_subnets["sbcntr-subnet-public-ingress-1c"]
      ]
      security_groups = [
        data.terraform_remote_state.common.outputs.vpc.sg["ingress"]
      ]
      lister = {
        port       = "80"
        protocol   = "HTTP"
        default_tg = "frontend_alb_blue"
      }
    }
  }
  target_group_frontend = {
    frontend_alb_blue = {
      lb           = "frontend_alb"
      name         = "sbcntr-tg-frontend-blue"
      health_check = "/healthcheck"
      port         = "80"
    }
    frontend_alb_green = {
      lb           = "frontend_alb"
      name         = "sbcntr-tg-frontend-green"
      health_check = "/healthcheck"
      port         = "80"
    }
  }
  listener_frontend_alb_green = {
    lb       = "frontend_alb"
    port     = "10080"
    protocol = "HTTP"
    tg       = "frontend_alb_green"
  }
}

#####################
# ECS Service
#####################
locals {
  ### Backend ###
  backend_ecs_service = {
    name            = "sbcntr-ecs-backend-service"
    task_definition = data.terraform_remote_state.application.outputs.ecs.ecs_task_definition_backend
    cluster         = data.terraform_remote_state.application.outputs.ecs.ecs_cluster_backend

    subnets = [
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-container-1a"],
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-container-1c"]
    ]
    security_groups = [
      data.terraform_remote_state.common.outputs.vpc.sg["backend"]
    ]

    # タスクの数
    desire_count = 1

    codedeploy_name                            = "sbcntr-ecs-backend-cluster"
    codedeploy_role                            = data.terraform_remote_state.application.outputs.codedeploy.codedeploy_role
    blue_green_deployment_wait_time_in_minutes = 10
    termination_wait_time_in_minutes           = 60

    namespace_id = data.terraform_remote_state.common.outputs.cloudmap.cloudmap_local.id
    vpc_id       = data.terraform_remote_state.common.outputs.vpc.vpc_id
  }

  ### Frontend ###
  frontend_ecs_service = {
    name            = "sbcntr-ecs-frontend-service"
    task_definition = module.ecs_service.ecs_task_definition_frontend
    cluster         = data.terraform_remote_state.application.outputs.ecs.ecs_cluster_frontend

    subnets = [
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-container-1a"],
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-container-1c"]
    ]
    security_groups = [
      data.terraform_remote_state.common.outputs.vpc.sg["frontend"]
    ]

    # タスクの数
    desire_count = 1

    codedeploy_name                            = "sbcntr-ecs-frontend-cluster"
    codedeploy_role                            = data.terraform_remote_state.application.outputs.codedeploy.codedeploy_role
    blue_green_deployment_wait_time_in_minutes = 10
    termination_wait_time_in_minutes           = 60

    namespace_id = data.terraform_remote_state.common.outputs.cloudmap.cloudmap_local.id
    vpc_id       = data.terraform_remote_state.common.outputs.vpc.vpc_id
  }
}

#####################
# ECS Task
#####################
locals {
  ecs_frontend = {
    task_definition = {
      name           = "sbcntr-ecs-frontend-def"
      container_name = "app"
      memory_soft    = 512
      cpu            = 256

      repository_url = data.terraform_remote_state.common.outputs.ecr.ecr_repositories_uri["sbcntr-frontend"]
      image_tag      = "dbv1"

      backendhost     = module.alb.internal_alb.internal_alb.dns_name
      secrets_manager = data.terraform_remote_state.application.outputs.aurora.secretsmanager_secret_db

      awslogs_group     = "/dev-ecs-handson/sbcntr-frontend-def"
      ecs_task_iam_name = "EcsTaskRole"
    }
    cluster = {
      name = "sbcntr-ecs-frontend-cluster"
    }
  }
}

#####################
# CodePipeline
#####################
locals {
  ### Backend ###
  codepipeline_backend = {
    pipeline_name = "sbcntr-pipeline"
    source = {
      reposiroty_name = data.terraform_remote_state.common.outputs.code_series.code_commit_backend_reposiroty_name
    }
    codebuild = {
      project_name = data.terraform_remote_state.common.outputs.code_series.code_build_backend_project_name
    }
    codedeploy = {
      application_name = module.ecs_service.ecs_backend_codedeploy_application_name
      deploy_group_name = module.ecs_service.ecs_backend_codedeploy_deploy_group_name
    }

  }

  ### Frontend ###
  codepipeline_frontend = {
    # 今は何もなし
  }
}