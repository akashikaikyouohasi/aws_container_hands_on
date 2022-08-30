resource "aws_vpc_endpoint" "endpoints" {
    for_each = var.endpoints

    vpc_id = var.vpc_id
    service_name = each.value.service_name
    vpc_endpoint_type = each.value.vpc_endpoint_type
    subnet_ids = each.value.subnet_ids
    security_group_ids = each.value.security_group_ids
    private_dns_enabled = true

    tags = {
        Name = each.value.name
    }
}