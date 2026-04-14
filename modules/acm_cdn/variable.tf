variable "project_name" {
    description = "Project Name"
    type        = string
}

variable "domain_name" {
    description = "Domain Name"
    type = string
}

variable "certificate_domain_name" {
    description = "Certificate Domain Name"
    type = string
}

variable "s3_website_endpoint" {
    description = "S3 Website Endpoint"
    type = string
}