##################
# NWリソース設定
##################

module "endpoints" {
  source = "../modules/endpoints"

  vpc_id = data.aws_vpc.vpc.id

  endpoints = local.endpoints
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
module "albs" {
  source = "../modules/alb"

  vpc_id = data.aws_vpc.vpc.id

  intenal_albs                = local.intenal_albs
  target_groups               = local.target_groups
  listener_internal_alb_green = local.listener_internal_alb_green
}

