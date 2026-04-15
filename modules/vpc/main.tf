# VPC 
resource "aws_vpc" "blog_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "${var.project_name}_vpc"
    }
}


# Internet Gateway
resource "aws_internet_gateway" "blog_igw" {
    vpc_id = aws_vpc.blog_vpc.id

    tags = {
        Name = "${var.project_name}_igw"
    }
}

# Public Subnet
resource "aws_subnet" "blog_public_subnet_1" {
    vpc_id = aws_vpc.blog_vpc.id
    cidr_block = var.public_subnet_cidr_1
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}_public_subnet_1"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.project_name}-${var.env_name}-cluster" = "shared"
    }
}

# Private Subnets
resource "aws_subnet" "blog_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.blog_vpc.id
  cidr_block        = "10.0.${count.index+10}.0/24"
  availability_zone = element(["ap-south-1b", "ap-south-1c"], count.index)
  tags              = { 
    Name = "blog_private_subnet_${count.index}" 
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.project_name}-${var.env_name}-cluster" = "shared"
    }
}

# Public Route Table
resource "aws_route_table" "blog_public_route_table" {
    vpc_id = aws_vpc.blog_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.blog_igw.id
    }
    tags = {
        Name = "${var.project_name}_public_route_table"
    }
}

# Public Route Table Association
resource "aws_route_table_association" "blog_public_route_table_association" {
    subnet_id = aws_subnet.blog_public_subnet_1.id
    route_table_id = aws_route_table.blog_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "blog_private_route_table" {
    vpc_id = aws_vpc.blog_vpc.id
    
    tags = {
        Name = "${var.project_name}_private_route_table"
    }
}

# Private Route Table Association
resource "aws_route_table_association" "blog_private_table_association" {
    count = 2
    subnet_id = aws_subnet.blog_private_subnet[count.index].id
    route_table_id = aws_route_table.blog_private_route_table.id
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.blog_public_subnet_1.id
    tags = {
        Name = "${var.project_name}_nat_gateway"
    }
}

resource "aws_route" "nat_route" {
    route_table_id = aws_route_table.blog_private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

output "vpc_id" {
    value = aws_vpc.blog_vpc.id
}

output "public_subnet_1_id" {
    value = aws_subnet.blog_public_subnet_1.id
}

output "private_subnet_1_id" {
    value = aws_subnet.blog_private_subnet[0].id
}

output "private_subnet_2_id" {
    value = aws_subnet.blog_private_subnet[1].id
}


