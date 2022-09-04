##################
# Cloud Map
##################
resource "aws_service_discovery_private_dns_namespace" "local" {
  # 名前空間
  name        = var.cloudmap.name
  description = var.cloudmap.name
  # 関連付けられたVPC
  vpc = var.vpc_id
}