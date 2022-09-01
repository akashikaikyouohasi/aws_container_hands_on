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
  }
}

#####################
# ALB
#####################
locals {
  intenal_albs = {
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