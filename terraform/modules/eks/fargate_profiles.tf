data "aws_iam_policy_document" "fargate_role" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["eks-fargate-pods.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "fargate_profile" {
  name               = "${var.cluster_name}-fargate-profile"
  assume_role_policy = data.aws_iam_policy_document.fargate_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile.name
}

resource "aws_eks_fargate_profile" "kube_system" {
  count                  = length(var.fargate_profiles)
  depends_on             = [null_resource.wait_for_cluster]
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "fargate-${var.fargate_profiles[count.index]}"
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = local.fargate_subnet_ids

  selector {
    namespace = var.fargate_profiles[count.index]
  }
}


###########


resource "kubernetes_namespace" "aws_observability" {
  depends_on = [null_resource.wait_for_cluster]
  metadata {
    annotations = {
      name = "aws-observability"
    }
    labels = {
      aws-observability = "enabled"
    }
    name = "aws-observability"
  }
}

resource "kubernetes_config_map" "aws_logging" {
  depends_on = [null_resource.wait_for_cluster]
  metadata {
    name      = "aws-logging"
    namespace = "aws-observability"
  }

  data = {
    "output.conf" = templatefile("${path.module}/templates/output.conf.tpl", {
      region  = data.aws_region.current.name
      project = var.cluster_name
      }
    )
    "parsers.conf" = file("${path.module}/templates/parsers.conf")
  }
}

data "aws_iam_policy_document" "aws_fargate_logging_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "aws_fargate_logging_policy" {
  name   = "aws_fargate_logging_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.aws_fargate_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_fargate_logging_policy_attach_role" {
  role       = aws_iam_role.fargate_profile.name
  policy_arn = aws_iam_policy.aws_fargate_logging_policy.arn
}
