locals {
  configmap_roles = [{
    rolearn  = aws_iam_role.AWSRoleForEKSNodeGroup.arn
    username = "system:node:{{EC2PrivateDNSName}}"
    groups = tolist(
      [
        "system:bootstrappers",
        "system:nodes"
      ]
    )
  }]
  fargate_roles = [{
    rolearn  = aws_iam_role.fargate_profile.arn
    username = "system:node:{{SessionName}}"
    groups = tolist(
      [
        "system:bootstrappers",
        "system:nodes",
        "system:node-proxier"
      ]
    )
  }]
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [aws_eks_cluster.this]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_command
    interpreter = var.local_exec_interpreter
    environment = {
      ENDPOINT = aws_eks_cluster.this.endpoint
    }
  }
}

resource "kubernetes_config_map" "aws_auth" {

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels = merge(
      {
        "app.kubernetes.io/managed-by" = "Terraform"
        "terraform.io/module"          = "terraform-eks-module"
      },
    )
  }

  data = {
    mapRoles = yamlencode(
      distinct(concat(
        local.configmap_roles,
        local.fargate_roles,
        var.map_roles,
      ))
    )
    mapUsers = yamlencode(var.map_users)
  }
}
