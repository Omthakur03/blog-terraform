resource "aws_security_group" "blog_rds_sg" {
    name = "blog_rds_sg"
    description = "Security group for RDS"
    vpc_id = var.blog_vpc_id
    ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "${var.project_name}-rds-sg"
    }
}

resource "aws_db_subnet_group" "blog_rds_subnet_group" {
    name = "${var.project_name}-rds-subnet-group"
    subnet_ids = var.private_subnet_ids

    tags = {
        Name = "${var.project_name}-rds-subnet-group"
    }
}

resource "aws_db_instance" "blog_rds" {

    depends_on = [aws_db_subnet_group.blog_rds_subnet_group, aws_security_group.blog_rds_sg]

    identifier = "${var.project_name}-rds"
    engine = "postgres"
    engine_version = "16.11"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    storage_type = "gp3"
    db_name = "blogdb"
    username = "postgres"
    password = var.rds_password
    db_subnet_group_name = aws_db_subnet_group.blog_rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.blog_rds_sg.id]
    skip_final_snapshot = true
    publicly_accessible = false

    tags = {
        Name = "${var.project_name}-rds"
    }
}

resource "aws_secretsmanager_secret" "blog_rds_secret" {
    name = "${var.project_name}-rds-secret"
    recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "blog_rds_secret_version" {
    secret_id = aws_secretsmanager_secret.blog_rds_secret.id
    secret_string = jsonencode({
        username = "postgres"
        password = var.rds_password
    })
}

output "rds_endpoint" {
    value = aws_db_instance.blog_rds.endpoint
}

output "rds_username" {
    value = aws_db_instance.blog_rds.username
}

output "rds_password" {
    value = aws_db_instance.blog_rds.password
}