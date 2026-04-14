resource "aws_security_group" "blog_rds_bastion_ec2_sg" {
    name = "${var.project_name}_rds_bastion_ec2_sg"
    description = "Security Group for RDS Bastion Host"
    vpc_id = var.blog_vpc_id
    # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Postgres Access (Optional: only if you need to connect from outside)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}_rds_bastion_ec2_sg"
    }
}

data "aws_ami" "amazon_linux_2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
}

resource "aws_instance" "blog_bastion_host" {
    depends_on = [aws_security_group.blog_rds_bastion_ec2_sg]
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = "t3.micro"
    key_name = "blog-bastion-host-key"
    subnet_id = var.public_subnet_id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.blog_rds_bastion_ec2_sg.id]
    tags = {
        Name = "${var.project_name}_bastion_host"
    }
}