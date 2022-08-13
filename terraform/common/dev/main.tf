terraform {
  # terraformのバージョン指定
  required_version = ">=1.0.8"

  # 使用するAWSプロバイダーのバージョン指定（結構更新が速い）
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.26.0"
    }
  }

  # tfstate(状態管理用ファイル)をS3に保存する設定
  backend "s3" {
    bucket = "tfstate-terraform-20211204"
    key    = "dev-ecs-handson/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# 明示的にAWSプロバイダを定義（暗黙的に理解してくれる）
provider "aws" {
  region  = "ap-northeast-1"

  # 作成する全リソースに付与するタグ設定
  default_tags {
    tags = {
      env = "dev"
      project_name = "dev-ecs-handson"
    }
  }
}

# グローバルリージョンにデプロイする必要があるもの用：Multiple Providers機能
provider "aws" {
  alias = "virginia"
  region  = "us-east-1"

  # 作成する全リソースに付与するタグ設定
  default_tags {
    tags = {
      env = "dev"
      project_name = "dev-ecs-handson"
    }
  }
}

##################
# リソース設定
##################
module "network" {
  source = "../modules/network"

  name = var.name

  cidr_block = local.cidr_block
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets

  security_group = local.security_group
  security_group_rule = local.security_group_rule
}

output "aws_vpc"{
  value = module.network
}