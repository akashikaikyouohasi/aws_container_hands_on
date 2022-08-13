resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    
    tags = {
        Name = var.name
    }
}

resource "aws_subnet" "public_subnets" {
    for_each = var.public_subnets

    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone

    tags = {
        Name = each.value.name
    }
}

resource "aws_subnet" "private_subnets" {
    for_each = var.private_subnets

    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.availability_zone

    tags = {
        Name = each.value.name
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = var.name
    }
}

resource "aws_route_table" "public_route_tables" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = var.name
    }
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public_subnets
    subnet_id = each.value.id
    route_table_id = aws_route_table.public_route_tables.id
}

#########################
# セキュリティグループ
#########################
resource "aws_security_group" "sg" {
    for_each = toset(var.security_group)

    name = each.key
    vpc_id = aws_vpc.vpc.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "sg_rule" {
    for_each = var.security_group_rule

    type              = "ingress"
    from_port         = each.value.port
    to_port           = each.value.port
    protocol          = each.value.protocol

    security_group_id = aws_security_group.sg[each.value.sg].id
    
    # source_security_group_idとcidr_blocksは排他運用
    source_security_group_id = each.value.source_security_group_id != null ? aws_security_group.sg[each.value.source_security_group_id].id : null
    cidr_blocks = each.value.cidr_blocks != null ? [each.value.cidr_blocks] : null

}
