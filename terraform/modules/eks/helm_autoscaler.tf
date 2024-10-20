##################################
# Variables for Cluster Autoscaler
##################################

variable "autoscaler_enabled" {
  default = false
}

variable "eks_autoscaler_ns" {
  type        = string
  default     = "cluster-autoscaler"
  description = "The namespace where cluster autoscaler will be deployed"
}

variable "eks_autoscaler_service_account" {
  type        = string
  default     = "cluster-autoscaler"
  description = "Service account in EKS for cluster autoscaler"
}

variable "eks_autoscaler_force_update" {
  type        = bool
  default     = false
  description = "This will force helm uninstall/install if true"
}

variable "eks_autoscaler_version" {
  type        = string
  default     = "9.4.0"
  description = "Force Autoscaler update through delete/recreate if needed"
}

###############################################
# IAM Roles and Policies for Cluster Autoscaler
###############################################

data "aws_iam_policy_document" "this_eks_autoscaler" {
  statement {
    sid    = "AllowEKSAutoscaling"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "this_eks_autoscaler_assume" {
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
        "system:serviceaccount:${var.eks_autoscaler_ns}:${var.eks_autoscaler_service_account}",
      ]
    }
  }
}

resource "aws_iam_policy" "AmazonEKSAutoscalerPolicy" {
  count       = var.autoscaler_enabled ? 1 : 0
  name        = "EKSAutoscaler-${var.cluster_name}"
  path        = "/"
  description = "Policy for EKS Autoscaler service"
  policy      = data.aws_iam_policy_document.this_eks_autoscaler.json
}

resource "aws_iam_role" "AmazonEKSAutoscalerRole" {
  count              = var.autoscaler_enabled ? 1 : 0
  name               = "EKSAutoscalerRole-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.this_eks_autoscaler_assume.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSAutoscalerPolicy" {
  count      = var.autoscaler_enabled ? 1 : 0
  policy_arn = aws_iam_policy.AmazonEKSAutoscalerPolicy[0].arn
  role       = aws_iam_role.AmazonEKSAutoscalerRole[0].name
}

####################################
# Helm Config for Cluster Autoscaler
####################################

resource "helm_release" "cluster_autoscaler" {
  count            = var.autoscaler_enabled ? 1 : 0
  depends_on       = [null_resource.wait_for_cluster]
  chart            = "cluster-autoscaler"
  namespace        = var.eks_autoscaler_ns
  create_namespace = true
  name             = "cluster-autoscaler"
  version          = var.eks_autoscaler_version
  repository       = "https://kubernetes.github.io/autoscaler"
  force_update     = var.eks_autoscaler_force_update

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = var.eks_autoscaler_service_account
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.AmazonEKSAutoscalerRole[0].arn
  }
}
