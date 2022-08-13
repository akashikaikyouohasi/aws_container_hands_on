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

variable "security_group" {
    description = "security group"
}
variable "security_group_rule" {
    description = "security group rule"
}