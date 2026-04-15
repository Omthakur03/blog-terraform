output "ProjectName" {
    value = var.project_name
}

output "ProjectRegion" {
    value = var.aws_region
}

output "DomainName" {
    value = module.cdn.DomainName
}

output "RDS_Endpoint" {
  value = var.is_prod ? module.rds[0].rds_endpoint : "Not Deployed in Staging"
}

output "RDS_Username" {
  value = var.is_prod ? module.rds[0].rds_username : "Not Deployed in Staging"
}

output "S3_Website_Endpoint" {
    value = module.s3.s3_website_endpoint
}

output "Repository_URLs" {
    value = module.ecr.respository_urls
}

output "certificate_arn" {
  value = module.acm.certificate_arn
}