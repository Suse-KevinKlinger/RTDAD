# ---------------------------------------------------------------------------------------------------------------------
#  Deploy the Cert-Manager to be used by Rancher UI
# ---------------------------------------------------------------------------------------------------------------------

resource "helm_release" "helm_cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_version
}

# ---------------------------------------------------------------------------------------------------------------------
#  Deploy the Rancher UI
# ---------------------------------------------------------------------------------------------------------------------

resource "helm_release" "rancherUI" {
  depends_on = [helm_release.helm_cert_manager]

  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = "cattle-system"
  version    = var.rancherUI_version

  set {
    name  = "hostname"
    value = var.rancherUI_address
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  Deploy Longhorn
# ---------------------------------------------------------------------------------------------------------------------

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
