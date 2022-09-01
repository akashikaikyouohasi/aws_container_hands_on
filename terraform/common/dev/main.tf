##################
# リソース設定
##################
# ネットワーク
module "network" {
  source = "../modules/network"

  name = var.name

  cidr_block      = local.cidr_block
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  public_route_table  = local.public_route_table
  private_route_table = local.private_route_table

  security_group      = local.security_group
  security_group_rule = local.security_group_rule

  endpoint_s3_gateway = local.endpoint_s3_gateway
}

output "vpc" {
  value = module.network
}

# ECR
module "ecr" {
  source = "../modules/ecr"
  ecr    = local.ecr
}
output "ecr" {
  value = module.ecr
}

# Cloud9
module "cloud9" {
  source           = "../modules/cloud9"
  cloud9           = local.cloud9
  public_subnets   = module.network.public_subnets
  sg               = module.network.sg
  ecr_repositories = module.ecr.ecr_repositories
}

output "cloud9" {
  value = module.cloud9
}