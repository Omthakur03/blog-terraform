terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

# The specific provider for ACM/CloudFront
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

