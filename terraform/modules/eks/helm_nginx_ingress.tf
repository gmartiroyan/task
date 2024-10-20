###########
# Variables
###########

variable "nginx_enabled" {
  default = false
}

variable "nginx_ingress_update" {
  type        = bool
  default     = false
  description = "This will force helm uninstall/install if true for Nginx ingress"
}

variable "nginx_ingress_version" {
  type        = string
  default     = "4.1.2"
  description = "The version of helm chart for Nginx ingress"
}


variable "nginx_ingress_namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "nginx_ingress_certificate_arn" {
  type    = string
  default = ""
}

variable "nginx_nodeselector_enable" {
  type    = bool
  default = false
}

#################
# Security Grpoup
#################

resource "aws_security_group" "sg_elb" {
  name        = "sg_elb_${var.cluster_name}"
  description = "ELB SG that allows traffic only from Cloudflare"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/13",
      "104.24.0.0/14", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15",
    "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "104.16.0.0/13",
      "104.24.0.0/14", "108.162.192.0/18", "131.0.72.0/22", "141.101.64.0/18", "162.158.0.0/15",
    "172.64.0.0/13", "173.245.48.0/20", "188.114.96.0/20", "190.93.240.0/20", "197.234.240.0/22", "198.41.128.0/17"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name       = "sg_elb_${var.cluster_name}"
    Automation = "terraform"
  }
}

#############
# Helm Config
#############

resource "helm_release" "nginx_ingress" {
  count            = var.nginx_enabled ? 1 : 0
  depends_on       = [null_resource.wait_for_cluster]
  chart            = "ingress-nginx"
  namespace        = var.nginx_ingress_namespace
  create_namespace = true
  name             = "ingress-nginx"
  version          = var.nginx_ingress_version
  repository       = "https://kubernetes.github.io/ingress-nginx"
  force_update     = var.nginx_ingress_update

  set {
    name  = "controller.service.targetPorts.https"
    value = "http"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
  }

  set {
    name  = "controller.replicaCount"
    value = var.nginx_replica_count
  }

  set {
    name  = "controller.service.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "true"
  }

  set {
    name  = "controller.service.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
    value = "true"
  }


  # The following dynamic block checks if node selector is enabled for Nginx ingress, if yes than there should be Node Group with the
  # special label `forService = "nginx"`, otherwise Nginx Ingress Controller will fail to start.

  dynamic "set" {
    for_each = try(var.nginx_nodeselector_enable ? ["nginx"] : tomap(false), {})
    content {
      name  = "controller.nodeSelector.forService"
      value = set.value
    }
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.nginx_ingress_certificate_arn
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "http"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "https"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-additional-resource-tags"
    value = "${var.cluster_name}-nginx-ingress"
  }

  # Enable prometheus metrics
  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }

  # Set ELB security group

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
    value = aws_security_group.sg_elb.id
  }
}
