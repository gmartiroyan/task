data "aws_region" "current" {}

data "aws_iam_policy_document" "this_eks" {
  statement {
    sid     = "AllowEKSAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "this_eks_ng" {
  statement {
    sid     = "AllowEKSNGAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "tls_certificate" "this_eks" {
  url        = aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on = [null_resource.wait_for_cluster]
}

data "aws_vpc" "this" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Name = "${var.vpc_name}-public-*"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  tags = {
    Name = "${var.vpc_name}-private-*"
  }
}
