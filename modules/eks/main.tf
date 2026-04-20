resource "aws_eks_cluster" "blog_cluster" {
  name     = "${var.project_name}-${var.env_name}-cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids             = var.private_subnet_ids
    endpoint_public_access = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_fargate_profile" "blog_fargate_profile" {
  cluster_name           = aws_eks_cluster.blog_cluster.name
  fargate_profile_name   = "${var.project_name}-${var.env_name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "blog-app"
  }

  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution
  ]
}

resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.blog_cluster.name
  fargate_profile_name   = "${var.project_name}-${var.env_name}-kube-system-profile"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  subnet_ids             = var.private_subnet_ids

  selector {
    namespace = "kube-system"
  }
}

# 1. Fargate Execution Role Entry (Keep this)
resource "aws_eks_access_entry" "fargate_execution_entry" {
  cluster_name  = aws_eks_cluster.blog_cluster.name
  principal_arn = "arn:aws:iam::345483430684:role/blog-prod-fargate-execution-role"
  type          = "FARGATE_LINUX"
}

# 2. Altaws-swesha Entry (Keep this)
resource "aws_eks_access_entry" "swesha_access" {
  cluster_name  = aws_eks_cluster.blog_cluster.name
  principal_arn = "arn:aws:iam::345483430684:user/Altaws-swesha"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "swesha_admin" {
  cluster_name  = aws_eks_cluster.blog_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_eks_access_entry.swesha_access.principal_arn
  access_scope {
    type = "cluster"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env_name}-alb-sg"
  vpc_id      = var.vpc_id # Passed from main.tf

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.env_name}-alb-sg"
  }
}

# Allow ALB to communicate with the EKS Cluster
resource "aws_security_group_rule" "alb_to_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.blog_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.alb_sg.id
}

# Allow Cluster (Fargate) to communicate with RDS
resource "aws_security_group_rule" "cluster_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_eks_cluster.blog_cluster.vpc_config[0].cluster_security_group_id
}