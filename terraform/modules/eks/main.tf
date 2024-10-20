/**
 * # Terraform Module for EKS
 *
 * ## Description
 * The module for creating/managing [AWS EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/clusters.html), EKS Node Groups, IAM Roles and Policies for Kubernetes Service Account mappings
 *
 * ## Usage:
 *
 * ```hcl
 * data "aws_eks_cluster_auth" "this" {
 *   name = module.eks.this_eks_id
 * }
 *
 * variable "cluster_name" {
 *   type    = string
 *   default = "bwt-eks"
 * }
 *
 * provider "kubernetes" {
 *   host                   = module.eks.this_eks_endpoint
 *   cluster_ca_certificate = module.eks.this_eks_ca
 *   token                  = data.aws_eks_cluster_auth.this.token
 * }
 *
 * provider "helm" {
 *   kubernetes {
 *     host                   = module.eks.this_eks_endpoint
 *     cluster_ca_certificate = module.eks.this_eks_ca
 *     token                  = data.aws_eks_cluster_auth.this.token
 *   }
 * }
 *
 * module "vpc" {
 *   source = "../modules/vpc"
 *   name   = "main-vpc"
 *
 *   cidr = "10.0.0.0/16"
 *   private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
 *   public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]
 *
 *   private_subnet_tags = {
 *     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
 *     "kubernetes.io/role/internal-elb"           = 1
 *     "tier"                                      = "private"
 *   }
 *
 *   public_subnet_tags = {
 *     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
 *     "kubernetes.io/role/elb"                    = 1
 *     "tier"                                      = "public"
 *   }
 *
 * }
 *
 * module "eks" {
 *   depends_on          = [module.vpc]
 *   source              = "../modules/eks"
 *   cluster_name        = var.cluster_name
 *   vpc_name            = module.vpc.name
 *   cluster_kms_key_arn = "arn:aws:kms:eu-north-1:111222333444:key/a1a2a3a4-b12b-c12c-d12d-e1e2e3e4e5e6"
 *
 *   node_groups = {
 *     ng-default = {
 *       name             = "ng-default"
 *       subnet_ids       = module.vpc.public_subnet_ids
 *       desired_capacity = 4
 *       max_size         = 6
 *       min_size         = 2
 *       instance_type    = "m5.large"
 *       disk_size        = 20
 *       capacity_type    = "ON_DEMAND"
 *       remote_access    = true
 *       ng_tags          = {
 *         "ng-type" = "default"
 *       }
 *     }
 *   }
 * }
 * ```
 */

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.AWSRoleForEKS.arn
  version  = var.cluster_version
  tags     = var.cluster_tags

  vpc_config {
    subnet_ids              = local.eks_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }
}

resource "aws_eks_node_group" "eks_cluster_ng" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value["remote_access"] == true ? format("%s-%s", each.value["name"], "ra") : each.value["name"]
  node_role_arn   = aws_iam_role.AWSRoleForEKSNodeGroup.arn
  subnet_ids      = each.value["subnet_ids"]
  capacity_type   = each.value["capacity_type"]

  instance_types = each.value["remote_access"] == false ? [each.value["instance_type"]] : null
  disk_size      = each.value["remote_access"] == false ? each.value["disk_size"] : null

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_size"]
    min_size     = each.value["min_size"]
  }

  dynamic "launch_template" {
    for_each = each.value["remote_access"] == true ? ["true"] : []
    content {
      id      = aws_launch_template.cluster[each.value["name"]].id
      version = aws_launch_template.cluster[each.value["name"]].latest_version
    }
  }


  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config.0.desired_size]
  }

  depends_on = [kubernetes_config_map.aws_auth]

  tags = merge(
    var.cluster_tags,
    each.value["ng_tags"]
  )
}
