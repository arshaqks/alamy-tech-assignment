provider "aws" {
  region = "ap-south-1"
}

# resource "aws_s3_bucket" "mys3bucket" {
#     bucket = "alamy-tech-asses-remote-state-file"
# }

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "prod-vpc"
  }
}

# module "network" {
# 	source           = ".//modules/infra"
# 	vpc_id     		 = aws_vpc.myvpc.id
# 	cidr_block		 = "10.0.1.0/24"
# 	name       	     = "prod-subnet"
# }



module "alamy_webserver" {
  source = ".//modules/infra"
  vpc_id = aws_vpc.myvpc.id
  #cidr_block      = cidrsubnet(aws_vpc.myvpc.cidr_block, 4, 1)
  cidr_block = "10.0.1.0/24"
  #subnet_id        = module.network.subnet_id
  name          = "prod-server"
  ami           = "ami-0e670eb768a5fc3d4"
  instance_type = "t2.micro"
  security_rules = {
    ingress = [{
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]
    egress = [{
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }]
  }

  tags = {
    name = "ec2_alamy"
  }
}

output "webserver" {
  value = module.alamy_webserver.instance
}

module "iam" {
  source         = ".//modules/iam"
  user           = "alamy-user"
  role           = "alamy-role"
  policy         = "alamy-policy"
  policy_actions = ["ec2:Describe*"]
}


