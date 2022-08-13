variable "name" {
    default = "sbcntrVpc"
}

locals {
    cidr_block = "10.0.0.0/16"
}

locals {
    subnets = {
        public-ingress-1a = {
            name = "sbcntr-subnet-public-ingress-1a"
            availability_zone = "ap-northeast-1a"
            cidr_block = "10.0.0.0/24"
        }
        public-ingress-1c = {
            name = "sbcntr-subnet-public-ingress-1c"
            availability_zone = "ap-northeast-1c"
            cidr_block = "10.0.1.0/24"
        }
        private-container-1a = {
            name = "sbcntr-subnet-private-container-1a"
            availability_zone = "ap-northeast-1a"
            cidr_block = "10.0.8.0/24"
        }
        private-container-1c = {
            name = "sbcntr-subnet-private-container-1c"
            availability_zone = "ap-northeast-1c"
            cidr_block = "10.0.9.0/24"
        }
        private-db-1a = {
            name = "sbcntr-subnet-private-db-1a"
            availability_zone = "ap-northeast-1a"
            cidr_block = "10.0.16.0/24"
        }
        private-db-1c = {
            name = "sbcntr-subnet-private-db-1c"
            availability_zone = "ap-northeast-1c"
            cidr_block = "10.0.17.0/24"
        }
        public-management-1a = {
            name = "sbcntr-subnet-public-management-1a"
            availability_zone = "ap-northeast-1a"
            cidr_block = "10.0.240.0/24"
        }
        public-management-1c = {
            name = "sbcntr-subnet-public-management-1c"
            availability_zone = "ap-northeast-1c"
            cidr_block = "10.0.241.0/24"
        }
    }
}