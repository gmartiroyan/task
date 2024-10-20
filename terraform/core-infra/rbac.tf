resource "kubernetes_cluster_role" "powerusers" {
  metadata {
    name = "powerusers"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "powerusers" {
  metadata {
    name = "poweruserss"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "powerusers"
  }
  subject {
    kind      = "Group"
    name      = "system:powerusers"
    api_group = "rbac.authorization.k8s.io"
  }
}
