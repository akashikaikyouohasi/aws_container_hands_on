output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnets" {
    description = "public サブネット名とid"
    value = [for value in aws_subnet.public_subnets : "${value.tags.Name}: ${value.id}" ]
}

output "private_subnets" {
    description = "private サブネット名とid"
    value = [for value in aws_subnet.private_subnets : "${value.tags.Name}: ${value.id}" ]
}