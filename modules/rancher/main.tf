resource "helm_release" "helm_cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "v1.0.4"
}

resource "helm_release" "rancherUI" {
  depends_on = [helm_release.helm_cert_manager]

  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"
  version    = "v2.5.6"

  set {
    name  = "hostname"
    value = var.rancherUI_address
  }
}

resource "helm_release" "longhorn" {

  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = "longhorn-system"

  set {
    name  = "name"
    value = "longhorn"
  }
}
