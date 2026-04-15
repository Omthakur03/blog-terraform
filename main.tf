# Fetch existing Route 53 Zone
data "aws_route53_zone" "main" {
  name         = "mzsk.fun"
  private_zone = false
}

module "vpc" {
  source       = "./modules/vpc"
  count = var.is_prod ? 1 : 0
  project_name = "${var.project_name}-${var.env_name}"
  vpc_cidr     = var.vpc_cidr
  public_subnet_cidr_1 = var.public_subnet_cidr_1
  env_name = var.env_name
  aws_region = var.aws_region
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  env_name     = var.env_name
}

module "cdn" {
  source              = "./modules/cdn"
  providers           = { aws = aws.virginia }
  project_name        = "${var.project_name}-${var.env_name}"
  domain_name         = var.domain_name
  zone_id      = data.aws_route53_zone.main.zone_id
  certificate_domain_name = var.certificate_domain_name
  s3_website_endpoint = module.s3.s3_website_endpoint
}


module "rds" {
  source             = "./modules/rds"
  count              = var.is_prod ? 1 : 0 # Logic switch
  project_name       = var.project_name
  blog_vpc_id        = var.is_prod ? module.vpc[0].vpc_id : ""
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = var.is_prod ? [module.vpc[0].private_subnet_1_id, module.vpc[0].private_subnet_2_id] : []
  rds_password       = var.rds_password
}

module "ec2" {
  source           = "./modules/ec2"
  count            = var.is_prod ? 1 : 0 # Logic switch
  project_name     = var.project_name
  blog_vpc_id      = var.is_prod ? module.vpc[0].vpc_id : ""
  public_subnet_id = var.is_prod ? module.vpc[0].public_subnet_1_id : ""
}

module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
  env_name     = var.env_name
  service_names = var.service_names
}

module "eks" {
  source       = "./modules/eks"
  project_name = var.project_name
  env_name     = var.env_name
  is_prod = var.is_prod
  vpc_id = module.vpc[0].vpc_id
  private_subnet_ids = [module.vpc[0].private_subnet_1_id, module.vpc[0].private_subnet_2_id]
  public_subnet_ids = [module.vpc[0].public_subnet_1_id]
}


module "acm" {
  source       = "./modules/acm"
  project_name = var.project_name
  env_name     = var.env_name
  zone_id      = data.aws_route53_zone.main.zone_id
  backend_domain_name = var.backend_domain_name
}