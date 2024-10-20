#####
# Launch Template with AMI
#####
data "aws_ssm_parameter" "cluster" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.this.version}/amazon-linux-2/recommended/image_id"
}

locals {
  ra_enabled_ngs = {
    for ngname, ngparams in var.node_groups : ngname => ngparams
    if ngparams.remote_access == true
  }
}

resource "aws_launch_template" "cluster" {
  for_each = {
    for ngname, ngparams in var.node_groups : ngname => ngparams
    if ngparams.remote_access == true
  }
  image_id               = data.aws_ssm_parameter.cluster.value
  instance_type          = each.value["instance_type"]
  name                   = "eks-lt-${var.cluster_name}-${each.key}"
  update_default_version = true
  key_name               = aws_key_pair.this_eks_ng[0].key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = each.value["disk_size"]
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name                                                 = "eks-node-group-instance-${each.value["name"]}"
      "kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
    }
  }

  user_data = base64encode(templatefile("${path.module}/templates/userdata.tpl", { CLUSTER_NAME = aws_eks_cluster.this.name, B64_CLUSTER_CA = aws_eks_cluster.this.certificate_authority[0].data, API_SERVER_URL = aws_eks_cluster.this.endpoint }))
}
