variable "project_name" {
    type = string
}

variable "env_name" {
    type = string
}

variable "is_prod" {
    type = bool
}

variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "rds_security_group_id" {
    type = string
}
