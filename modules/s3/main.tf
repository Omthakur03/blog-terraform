resource "random_string" "random_string" {
    length = 4
    special = false
    upper = false
}

resource "aws_s3_bucket" "blog_bucket" {
    bucket = "${var.project_name}-${var.env_name}-bucket-${random_string.random_string.result}"

    force_destroy = true
    tags = {
        Name = "${var.project_name}-${var.env_name}-bucket-${random_string.random_string.result}"
    }
}

resource "aws_s3_bucket_website_configuration" "blog_bucket_website" {
    bucket = aws_s3_bucket.blog_bucket.id
    index_document {
        suffix = "index.html"
    }
}

resource "aws_s3_bucket_public_access_block" "blog_bucket_public_access_block" {
    bucket = aws_s3_bucket.blog_bucket.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "blog_bucket_policy" {
    bucket = aws_s3_bucket.blog_bucket.id

    depends_on = [aws_s3_bucket_public_access_block.blog_bucket_public_access_block]
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "s3:GetObject"
                Effect = "Allow"
                Principal = "*"
                Resource = "${aws_s3_bucket.blog_bucket.arn}/*"
            }
        ]
    })
}

resource "aws_s3_object" "index_html" {
    bucket = aws_s3_bucket.blog_bucket.id
    key    = "index.html"
    source = "./modules/s3/index.html"
    content_type = "text/html"
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.blog_bucket.bucket_regional_domain_name
}

output "s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.blog_bucket_website.website_endpoint
}