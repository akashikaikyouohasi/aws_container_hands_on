variable "name" {
    description = "Name"
    type        = string
}

variable "cidr_block" {
    description = "VPCのCIDR"
    type        = string
}

variable "subnets" {
    description = "subnetのmap"
}
