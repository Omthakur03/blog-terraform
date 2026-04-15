# 1. ALB Security Group (Stays the same)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Rule: Allow ALB to talk to Fargate Pods
# In Fargate, we use the cluster's primary security group
resource "aws_security_group_rule" "alb_to_cluster" {
  description              = "Allow ALB to reach Fargate pods"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.blog_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.alb_sg.id
}

# 3. Rule: Allow Fargate Pods to talk to RDS
resource "aws_security_group_rule" "cluster_to_rds" {
  description              = "Allow Fargate pods to reach PostgreSQL"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_eks_cluster.blog_cluster.vpc_config[0].cluster_security_group_id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}