resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    
    tags = {
        Name = var.name
    }
}

resource "aws_subnet" "subnets" {
    for_each = var.subnets

    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone

    tags = {
        Name = each.value.name
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.name
    }
}