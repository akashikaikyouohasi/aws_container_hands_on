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
  code_commit      = local.code_commit
}

output "cloud9" {
  value = module.cloud9
}

# Cloud Map
module "cloudmap" {
  source   = "../modules/cloudmap"
  cloudmap = local.cloudmap
  vpc_id   = module.network.vpc_id
}
output "cloudmap" {
  value = module.cloudmap
}

# Systems Manager Parameter Store
module "parameter_store" {
  source           = "../modules/parameter_store"
  secret_parameter = local.secret_parameter
}
output "parameter_store" {
  value     = module.parameter_store
  sensitive = true
}

# code series
module "code_series" {
  source      = "../modules/code_series"
  code_commit = local.code_commit
}
output "code_series" {
  value = module.code_series
}