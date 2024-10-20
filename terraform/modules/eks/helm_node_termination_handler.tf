############################################
# Variables for AWS Node Termination Handler
############################################

variable "node_termination_handler_enabled" {
  default = false
}

variable "node_termination_handler_ns" {
  type        = string
  default     = "aws-node-termination-handler"
  description = "EKS Namespace where AWS Node Termination Handler will be deployed"
}

variable "node_termination_handler_version" {
  type        = string
  default     = "0.15.0"
  description = "Version number for AWS Node Termination Handler"
}

variable "node_termination_handler_upgrade" {
  type        = bool
  default     = false
  description = "Force AWS Node Termination Handler update through delete/recreate if needed"
}

##############################################
# Helm Config for AWS Node Termination Handler
##############################################

resource "helm_release" "node_termination_handler" {
  count            = var.node_termination_handler_enabled ? 1 : 0
  chart            = "aws-node-termination-handler"
  name             = "aws-node-termination-handler"
  repository       = "https://aws.github.io/eks-charts"
  version          = var.node_termination_handler_version
  create_namespace = true
  force_update     = var.node_termination_handler_upgrade
  namespace        = var.node_termination_handler_ns

  set {
    name  = "enableSpotInterruptionDraining"
    value = true
  }
}
