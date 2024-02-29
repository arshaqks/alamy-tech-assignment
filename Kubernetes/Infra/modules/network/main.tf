locals {
  name = "${var.env}-${var.project_name}-${var.region}"
}
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default" #default/dedicated
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${local.name}-VPC-1"
    project_name = var.project_name
    environment = var.env
    region = var.region
    Resource = "VPC"
    Creation_time = timestamp()
  }
}

resource "aws_subnet" "pub_sub" {
    count = length(var.pub_sub_cidr)
    cidr_block = var.pub_sub_cidr[count.index]
    vpc_id = aws_vpc.vpc1.id
    availability_zone = var.availability_zone[count.index]
    map_public_ip_on_launch = true
    tags = {
      Name = "${local.name}-PUB-SUB-${count.index+1}"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "SUBNET"
      Creation_time = timestamp()
  }
  depends_on = [ aws_vpc.vpc1 ]
}

resource "aws_subnet" "pvt_sub" {
  count = length(var.pvt_sub_cidr)
  vpc_id = aws_vpc.vpc1.id
  cidr_block = var.pvt_sub_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  map_public_ip_on_launch = false
  tags = {
      Name = "${local.name}-PVT-SUB-${count.index+1}"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "SUBNET"
      Creation_time = timestamp()
  }
  depends_on = [ aws_vpc.vpc1 ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
      Name = "${local.name}-IGW-1"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "IGW"
      Creation_time = timestamp()
  }
  depends_on = [ aws_vpc.vpc1 ]
}

resource "aws_default_route_table" "pub_route_table_default" {
  default_route_table_id = aws_vpc.vpc1.default_route_table_id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      Name = "${local.name}-PUB-RTABLE-1"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "ROUTE_TABLE"
      Creation_time = timestamp()
  }
}

resource "aws_nat_gateway" "nat_gateway1" {
  subnet_id = aws_subnet.pub_sub[0].id
  allocation_id = aws_eip.eip1.allocation_id
  tags = {
      Name = "${local.name}-NATGW-1"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "NAT-GATEWAY"
      Creation_time = timestamp()
  }
}


resource "aws_eip" "eip1" {
  domain = "vpc"
#   public_ipv4_pool = "ipv4pool-ec2-012345"
  tags = {
      Name = "${local.name}-EIP-1"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "ROUTE_TABLE"
      Creation_time = timestamp()
  }
}

resource "aws_route_table" "pvt_route_table" {
  vpc_id = aws_vpc.vpc1.id
  route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
  }
  tags = {
      Name = "${local.name}-PVT-RTABLE-1"
      project_name = var.project_name
      environment = var.env
      region = var.region
      Resource = "ROUTE_TABLE"
      Creation_time = timestamp()
  }
}

resource "aws_route_table_association" "pvt_route_table_association1" {
  subnet_id = aws_subnet.pvt_sub[count.index].id
  route_table_id = aws_route_table.pvt_route_table.id
  count = length(var.pvt_sub_cidr)
}

output "pvt_subnets" {
  value = aws_subnet.pvt_sub[*].id
}

# resource "aws_db_subnet_group" "default" {
#   name       = "db-subnet"
#   subnet_ids = [aws_subnet.pub_sub[0].id,aws_subnet.pub_sub[1].id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }