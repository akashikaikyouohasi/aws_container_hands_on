#####################
# NWリソース
#####################
variable "name" {
  default = "sbcntrVpc"
}

locals {
  cidr_block = "10.0.0.0/16"
}

locals {
  public_subnets = {
    public-ingress-1a = {
      name              = "sbcntr-subnet-public-ingress-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.0.0/24"
      route_table_name  = "ingress"
    }
    public-ingress-1c = {
      name              = "sbcntr-subnet-public-ingress-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.1.0/24"
      route_table_name  = "ingress"
    }
    public-management-1a = {
      name              = "sbcntr-subnet-public-management-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.240.0/24"
      route_table_name  = "management"
    }
    public-management-1c = {
      name              = "sbcntr-subnet-public-management-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.241.0/24"
      route_table_name  = "management"
    }
  }

  private_subnets = {
    private-container-1a = {
      name              = "sbcntr-subnet-private-container-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.8.0/24"
      route_table_name  = "app"
    }
    private-container-1c = {
      name              = "sbcntr-subnet-private-container-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.9.0/24"
      route_table_name  = "app"
    }
    private-db-1a = {
      name              = "sbcntr-subnet-private-db-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.16.0/24"
      route_table_name  = "db"
    }
    private-db-1c = {
      name              = "sbcntr-subnet-private-db-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.17.0/24"
      route_table_name  = "db"
    }
    private-egress-1a = {
      name              = "sbcntr-subnet-private-egress-1a"
      availability_zone = "ap-northeast-1a"
      cidr_block        = "10.0.248.0/24"
      route_table_name  = "egress"
    }
    private-egress-1c = {
      name              = "sbcntr-subnet-private-egress-1c"
      availability_zone = "ap-northeast-1c"
      cidr_block        = "10.0.249.0/24"
      route_table_name  = "egress"
    }
  }
}

locals {
  public_route_table = {
    ingress = {
      name = "ingress"
    }
    management = {
      name = "management"
    }
  }
  private_route_table = {
    app = {
      name = "app"
    }
    db = {
      name = "db"
    }
    egress = {
      name = "egress"
    }

  }
}

locals {
  security_group = ["ingress", "frontend", "internal_alb", "backend", "db", "management", "egress"]
  security_group_rule = {
    ingress = {
      sg                       = "ingress"
      port                     = 0
      protocol                 = "-1"
      source_security_group_id = null
      cidr_blocks              = "0.0.0.0/0"
    }
    frontend = {
      sg                       = "frontend"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = "ingress"
      cidr_blocks              = null
    }
    internal_alb = {
      sg                       = "internal_alb"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = "frontend"
      cidr_blocks              = null
    }
    internal_alb_2 = {
      sg                       = "internal_alb"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = "management"
      cidr_blocks              = null
    }
    internal_alb_3 = {
      sg                       = "internal_alb"
      port                     = 10080
      protocol                 = "tcp"
      source_security_group_id = "management"
      cidr_blocks              = null
    }
    backend = {
      sg                       = "backend"
      port                     = 80
      protocol                 = "tcp"
      source_security_group_id = "internal_alb"
      cidr_blocks              = null
    }
    db = {
      sg                       = "db"
      port                     = 3306
      protocol                 = "tcp"
      source_security_group_id = "backend"
      cidr_blocks              = null
    }
    db_2 = {
      sg                       = "db"
      port                     = 3306
      protocol                 = "tcp"
      source_security_group_id = "frontend"
      cidr_blocks              = null
    }
    db_3 = {
      sg                       = "db"
      port                     = 3306
      protocol                 = "tcp"
      source_security_group_id = "management"
      cidr_blocks              = null
    }
    egress = {
      sg                       = "egress"
      port                     = 443
      protocol                 = "tcp"
      source_security_group_id = "frontend"
      cidr_blocks              = null
    }
    egress_2 = {
      sg                       = "egress"
      port                     = 443
      protocol                 = "tcp"
      source_security_group_id = "backend"
      cidr_blocks              = null
    }
    egress_3 = {
      sg                       = "egress"
      port                     = 443
      protocol                 = "tcp"
      source_security_group_id = "management"
      cidr_blocks              = null
    }
  }
}

locals {
  endpoint_s3_gateway = {
    name             = "sbcntr-vpce-s3"
    route_table_name = "app"
  }
}

#####################
# ECR
#####################
locals {
  ecr = {
    backend = {
      name         = "sbcntr-backend"
      scan_on_push = false
    }
    frontend = {
      name         = "sbcntr-frontend"
      scan_on_push = false
    }
  }
}


#####################
# build環境
#####################
locals {
  cloud9 = {
    name        = "sbcntr-dev"
    description = "Cloud9 for application development"

    connection_type = "CONNECT_SSH"
    instance_type   = "t2.micro"

    subnet_id      = local.public_subnets.public-management-1a.name
    security_group = "management"

    owner_arn = "arn:aws:iam::206863353204:user/test"
  }
}

#####################
# Cloud Map
#####################
locals {
  cloudmap = {
    name = "local"
  }
}

#####################
# Systems Manager Parameter Store
####################
locals {
  secret_parameter = {
    db_master_user = {
      name  = "/database/master/user"
      value = "admin"
    }
    db_master_password = {
      name  = "/database/master/password"
      value = "tmp"
    }
  }
}

#####################
# Code Series
#####################
locals {
  code_commit = {
    backend = {
      repository_name = "sbcntr-backend"
    }
  }
}