variable "project_name" {
    description = "Project Name"
    type = string
}

variable "aws_region" {
    description = "AWS Region"
    type        = string
    default     = "ap-south-1"
}

variable "vpc_cidr" {
    description = "VPC CIDR Block"
    type        = string    
}

variable "public_subnet_cidr_1" {
    description = "Public Subnet 1 CIDR Block"
    type        = string
    default     = "10.0.1.0/24"
}

variable "domain_name" {
    description = "Domain Name"
    type = string
}

variable "certificate_domain_name" {
    description = "Certificate Domain Name"
    type = string
}

variable "rds_password" {
    description = "RDS Password"
    type = string
    sensitive = true
}


variable "is_prod" {
  type        = bool
  description = "If true, deploy RDS and EC2. If false, skip them."
}

variable "env_name" {
  type        = string
  description = "Used for resource naming (e.g., staging or prod)"
}

