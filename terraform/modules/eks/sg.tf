locals {
  remote_access_allowed_ng = [
    for el in var.node_groups : el["name"] if el["remote_access"] == true
  ]
}

resource "aws_security_group" "allow_ng_ssh" {
  for_each    = toset(local.remote_access_allowed_ng)
  name        = "ssh-${var.cluster_name}-${each.value}"
  description = "Allow SSH to ${each.value} of ${var.cluster_name} cluster"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-${var.cluster_name}-${each.value}-ssh"
  }
}
