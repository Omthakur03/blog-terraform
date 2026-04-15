resource "aws_eks_cluster" "blog_cluster" {
  name     = "${var.project_name}-${var.env_name}-cluster"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
    # We keep endpoint_public_access true so you can run kubectl from home
    endpoint_public_access = true 
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_fargate_profile" "blog_fargate_profile" {
  cluster_name           = aws_eks_cluster.blog_cluster.name
  fargate_profile_name   = "${var.project_name}-${var.env_name}-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_role.arn
  
  # Fargate pods MUST run in private subnets
  subnet_ids = var.private_subnet_ids

  # This selector picks up your microservices
  selector {
    namespace = "blog-app"
  }

  # This selector allows CoreDNS (system pods) to run on Fargate
  selector {
    namespace = "kube-system"
    labels = {
      "k8s-app" = "kube-dns"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution
  ]
}