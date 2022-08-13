variable "name" {
    default = "sbcntrVpc"
}

locals {
    cidr_block = "10.0.0.0/16"
}

locals {
    public_subnets = {
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

locals {
    private_subnets = {
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
    }
}

locals {
    security_group = ["ingress", "frontend", "internal_alb", "backend", "db", "management"]
    security_group_rule = {
        ingress = {
            sg = "ingress"
            port = 0
            protocol = "-1"
            source_security_group_id = null
            cidr_blocks = "0.0.0.0/0"
        }
        frontend = {
            sg = "frontend"
            port = 80
            protocol = "tcp"
            source_security_group_id = "ingress"
            cidr_blocks = null
        }
        internal_alb = {
            sg = "internal_alb"
            port = 80
            protocol = "tcp"
            source_security_group_id = "frontend"
            cidr_blocks = null
        }
        internal_alb_2 = {
            sg = "internal_alb"
            port = 80
            protocol = "tcp"
            source_security_group_id = "management"
            cidr_blocks = null
        }
        backend = {
            sg = "backend"
            port = 80
            protocol = "tcp"
            source_security_group_id = "internal_alb"
            cidr_blocks = null
        }
        db = {
            sg = "db"
            port = 3306
            protocol = "tcp"
            source_security_group_id = "backend"
            cidr_blocks = null
        }
        db_2 = {
            sg = "db"
            port = 3306
            protocol = "tcp"
            source_security_group_id = "management"
            cidr_blocks = null
        }
    }
}