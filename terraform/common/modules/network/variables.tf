variable "name" {
    description = "Name"
    type        = string
}

variable "cidr_block" {
    description = "VPCのCIDR"
    type        = string
}

variable "public_subnets" {
    description = "public subnetのmap"
}
variable "private_subnets" {
    description = "private subnetのmap"
}

variable "public_route_table" {}
variable "private_route_table" {}

variable "security_group" {}
variable "security_group_rule" {}

variable "endpoint_s3_gateway" {}