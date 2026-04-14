variable "project_name" {
    description = "Project Name"
    type = string
}

variable "blog_vpc_id" {
    description = "Blog VPC ID"
    type = string
}

variable "vpc_cidr" {
    description = "VPC CIDR Block"
    type = string
}

variable "private_subnet_ids" {
    description = "Private Subnet ID"
    type = list(string)
}

variable "rds_password" {
    description = "RDS Password"
    type = string
}