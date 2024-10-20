######################
# Helm Config NewRelic
######################

resource "helm_release" "newrelic" {
  count            = var.newrelic_licensekey != "" ? 1 : 0
  depends_on       = [null_resource.wait_for_cluster]
  name             = "newrelic-bundle"
  chart            = "nri-bundle"
  create_namespace = true
  repository       = "https://helm-charts.newrelic.com"
  version          = "4.5.8"
  namespace        = "newrelic"
  timeout          = "1200"
  description      = "NewRelic Helm Chart deployment configuration"

  values = local.newrelic_values

  set {
    name  = "global.licenseKey"
    value = var.newrelic_licensekey
  }

  set {
    name  = "global.cluster"
    value = var.cluster_name
  }

  set {
    name  = "newrelic-infrastructure.privileged"
    value = true
  }

  set {
    name  = "global.lowDataMode"
    value = true
  }

  set {
    name  = "ksm.enabled"
    value = true
  }

  set {
    name  = "kubeEvents.enabled"
    value = true
  }

  set {
    name  = "prometheus.enabled"
    value = false
  }

  set {
    name  = "logging.enabled"
    value = true
  }
}
