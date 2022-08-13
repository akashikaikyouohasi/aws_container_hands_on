output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "subnets" {
    description = "サブネット名とid"
    value = [for value in aws_subnet.subnets : "${value.tags.Name}: ${value.id}" ]
}
