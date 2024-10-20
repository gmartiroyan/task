##############################
# Variables for Metrics Server
##############################

variable "metrics_enabled" {
  default = false
}

variable "metrics_server_force_update" {
  default = false
}

variable "metrics_server_namespace" {
  default = "kube-system"
}

################################
# Helm Config for Metrics Server
################################

resource "helm_release" "metrics_server" {
  count        = var.metrics_enabled ? 1 : 0
  chart        = "metrics-server"
  namespace    = var.metrics_server_namespace
  name         = "metrics-server"
  version      = "3.8.2"
  repository   = "https://kubernetes-sigs.github.io/metrics-server"
  force_update = var.metrics_server_force_update
}
