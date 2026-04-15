resource "aws_eks_cluster" "blog_cluster" {
    name = "${var.project_name}-${var.env_name}-cluster"
    role_arn = aws_iam_role.cluster_role.arn
    version="1.31"

    vpc_config {
        subnet_ids = var.private_subnet_ids
        endpoint_private_access = true
        endpoint_public_access = true #check with chinmay sir
    }

    depends_on = [
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
    ]

    tags = {
        Name = "${var.project_name}-${var.env_name}-cluster"
    }
}

resource "aws_eks_node_group" "nodes" {
    cluster_name = aws_eks_cluster.blog_cluster.name
    node_group_name = "${var.project_name}-${var.env_name}-node-group"
    node_role_arn = aws_iam_role.node_role.arn
    subnet_ids = var.private_subnet_ids

    instance_types = var.is_prod ? ["t3.micro"] : ["t2.micro"]
    scaling_config {
        desired_size = var.is_prod ? 1 : 1
        min_size = var.is_prod ? 1 : 1
        max_size = var.is_prod ? 2 : 1
    }

    update_config {
        max_unavailable = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
        aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
    ]

    tags = {
        Name = "${var.project_name}-${var.env_name}-node-group"
    }
}