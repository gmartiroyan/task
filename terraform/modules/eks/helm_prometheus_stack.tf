############################
# Helm Config for Prometheus
############################

variable "prometheus_enabled" {
  default = false
}

resource "helm_release" "prometheus_stack" {
  count            = var.prometheus_enabled ? 1 : 0
  depends_on       = [null_resource.wait_for_cluster]
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "36.6.1"
  namespace        = "prometheus"
  timeout          = "1200"
  description      = "Prometheus Helm Chart deployment configuration"

  set {
    name  = "alertmanager.enabled"
    value = false
  }

  set {
    name  = "grafana.enabled"
    value = false
  }

}
