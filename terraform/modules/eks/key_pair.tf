resource "tls_private_key" "this" {
  count     = length(local.remote_access_allowed_ng) > 0 ? 1 : 0
  algorithm = "RSA"
}

resource "aws_key_pair" "this_eks_ng" {
  count      = length(local.remote_access_allowed_ng) > 0 ? 1 : 0
  key_name   = "${var.cluster_name}-ng-key"
  public_key = tls_private_key.this[0].public_key_openssh
}


resource "tls_private_key" "this_local" {
  algorithm = "RSA"
}

resource "aws_key_pair" "this_eks_ng_local" {
  key_name   = "${var.cluster_name}-ng-key-local"
  public_key = tls_private_key.this_local.public_key_openssh
}
