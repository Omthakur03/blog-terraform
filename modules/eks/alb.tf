data "tls_certificate" "eks" {
    url = aws_eks_cluster.blog_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.blog_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "alb_controller_role" {
    name = "${var.project_name}-${var.env_name}-alb-controller-role"

    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRoleWithWebIdentity"
            Effect = "Allow"
            Principal = {
                Federated = aws_iam_openid_connect_provider.eks.arn
            }
            Condition = {
                StringEquals = {
                    "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }]
    })
}

resource "aws_iam_role_policy" "alb_controller_policy" {
    name = "AWSLoadBalancerControllerIAMPolicy"
    role = aws_iam_role.alb_controller_role.name
    policy = file("modules/eks/alb-controller-policy.json")
}