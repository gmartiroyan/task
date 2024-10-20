variable "aws_lb_enabled" {
  default = true
}

###############################################
# IAM Roles and Policies for Cluster Autoscaler
###############################################

data "aws_iam_policy_document" "this_eks_aws_lb_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.AWSIdentityOICD.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller",
      ]
    }
  }
}

resource "aws_iam_policy" "AWSLBPolicy" {
  count       = var.aws_lb_enabled ? 1 : 0
  name        = "AWSEKSLB-${var.cluster_name}"
  path        = "/"
  description = "Policy for EKS Autoscaler service"
  policy      = file("${path.module}/templates/aws_lb_policy.json")
}

resource "aws_iam_role" "AmazonEKSAWSLBRole" {
  count              = var.aws_lb_enabled ? 1 : 0
  name               = "AmazonEKSAWSLB-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.this_eks_aws_lb_assume.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSAWSLBPolicy" {
  count      = var.aws_lb_enabled ? 1 : 0
  policy_arn = aws_iam_policy.AWSLBPolicy[0].arn
  role       = aws_iam_role.AmazonEKSAWSLBRole[0].name
}


resource "helm_release" "aws_lb" {
  count            = var.aws_lb_enabled ? 1 : 0
  chart            = "aws-load-balancer-controller"
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  version          = "1.9.1"
  create_namespace = true
  force_update     = false
  namespace        = "kube-system"

  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.AmazonEKSAWSLBRole[0].arn
  }

  set {
    name = "vpcId"
    value = data.aws_vpc.this.id
  }
}
