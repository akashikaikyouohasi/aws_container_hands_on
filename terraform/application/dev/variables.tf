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

#####################
# Aurora
#####################
locals {
  aurora = {
    db_subnet_group_name = "sbcntr-rds-subnet-group"
    subnet_ids = [
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-db-1a"],
      data.terraform_remote_state.common.outputs.vpc.private_subnets["sbcntr-subnet-private-db-1c"]
    ]

    engine             = "aurora-mysql"
    engine_version     = "5.7.mysql_aurora.2.10.2"
    cluster_identifier = "sbcntr-db"
    master_username    = data.terraform_remote_state.common.outputs.parameter_store.secret_parameter["db_master_user"].value
    master_password    = data.terraform_remote_state.common.outputs.parameter_store.secret_parameter["db_master_password"].value

    instance_class = "db.t3.small"
    instances = {
      db1 = {
        identifier = "sbcntr-db-instance-1"
      }
      db2 = {
        identifier = "sbcntr-db-instance-2"
      }
    }

    vpc_security_group_ids = [
      data.terraform_remote_state.common.outputs.vpc.sg["db"]
    ]
    database_name = "sbcntrapp"

    backup_retention_period = 1
    monitoring_iam_role     = "sbcntr-rds-monitoring-role"
  }
}