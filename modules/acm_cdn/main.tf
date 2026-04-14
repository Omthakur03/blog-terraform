resource "aws_acm_certificate" "blog_certificate" {
    domain_name = var.certificate_domain_name
    validation_method = "DNS"
}


# CloudFront
resource "aws_cloudfront_origin_access_control" "blog_oac" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "blog_distribution" {

  aliases = [var.certificate_domain_name]

  origin {
    # Use the website endpoint string here
    domain_name = var.s3_website_endpoint 
    origin_id   = "S3WebsiteOrigin"

    # Important: Since it's a website endpoint, we use custom_origin_config
    # NOT origin_access_control_id
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only" # S3 Website endpoints only support HTTP
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  default_root_object = ""

  default_cache_behavior {
    target_origin_id       = "S3WebsiteOrigin"
    viewer_protocol_policy = "redirect-to-https"
    
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.blog_certificate.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  tags = {
    Name = "${var.project_name}-cloudfront"
  }
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.blog_distribution.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.blog_distribution.domain_name
}

