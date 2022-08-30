#####################
# NWリソース
#####################
locals {
    vpc_name = "sbcntrVpc"
}

locals {
    endpoints = {
        ecr_api_endpoint = {
            name = "sbcntr-vpce-ecr-api"
            service_name = "com.amazonaws.ap-northeast-1.ecr.api"
            vpc_endpoint_type = "Interface"
            #subnet_ids = data.aws_subnets.subnets_ecr.ids
            subnet_ids = data.aws_subnets.subnets["ecr_api_endpoint"].ids
            #security_group_ids = data.aws_security_groups.security_group_ecr.ids 
            security_group_ids = data.aws_security_groups.security_groups["ecr_api_endpoint"].ids
        }
        ecr_dkr_endpoint = {
            name = "sbcntr-vpce-ecr-dkr"
            service_name = "com.amazonaws.ap-northeast-1.ecr.dkr"
            vpc_endpoint_type = "Interface"
            subnet_ids = data.aws_subnets.subnets["ecr_dkr_endpoint"].ids
            security_group_ids = data.aws_security_groups.security_groups["ecr_dkr_endpoint"].ids
        }
        cloudwatch_logs_endpoint = {
            name = "sbcntr-vpce-logs"
            service_name = "com.amazonaws.ap-northeast-1.logs"
            vpc_endpoint_type = "Interface"
            subnet_ids = data.aws_subnets.subnets["cloudwatch_logs_endpoint"].ids
            security_group_ids = data.aws_security_groups.security_groups["cloudwatch_logs_endpoint"].ids
        }
    }
}

# subnetとSGの名前は、上記のendpointsの名前と同じにすること
locals {
    sbunet = {
        ecr_api_endpoint = "sbcntr-subnet-private-egress*"
        ecr_dkr_endpoint = "sbcntr-subnet-private-egress*"
        cloudwatch_logs_endpoint = "sbcntr-subnet-private-egress*"
    }
    sg = {
        ecr_api_endpoint = "egress"
        ecr_dkr_endpoint = "egress"
        cloudwatch_logs_endpoint = "egress"
    }
}
