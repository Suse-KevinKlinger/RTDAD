# ---------------------------------------------------------------------------------------------------------------------
#  Create the namespace to be used
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "di_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "rancher_ui_ns" {
  metadata {
    name = "cattle-system"
  }
}

resource "kubernetes_namespace" "rancher_cert_ns" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "longhorn_ns" {
  metadata {
    name = "longhorn-system"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  Create the ceph secrets
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "ceph-admin-secret" {
  depends_on = [kubernetes_namespace.di_namespace]

  metadata {
    name      = "ceph-admin-secret"
    namespace = var.namespace
  }

  data = {
    key = var.ceph_admin_secret
  }

  type = "kubernetes.io/rbd"
}

resource "kubernetes_secret" "ceph-user-secret" {
  depends_on = [kubernetes_namespace.di_namespace]

  metadata {
    name      = "ceph-user-secret"
    namespace = var.namespace
  }

  data = {
    key = var.ceph_user_secret
  }

  type = "kubernetes.io/rbd"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Create storage class
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_storage_class" "ceph" {
  metadata {
    name = "ceph"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = var.useLonghorn ? "false" : "true"
    }
  }
  storage_provisioner = "kubernetes.io/rbd"
  reclaim_policy      = "Delete"
  parameters = {
    adminId              = "admin",
    adminSecretName      = "ceph-admin-secret",
    adminSecretNamespace = "default",
    imageFeatures        = "layering",
    imageFormat          = "2",
    monitors             = "192.168.180.33:6789, 192.168.180.34:6789, 192.168.180.35:6789",
    pool                 = "di_pool",
    userId               = "admin",
    userSecretName       = "ceph-user-secret"
  }
  volume_binding_mode = "Immediate"
}

resource "kubernetes_storage_class" "longhorn" {
  metadata {
    name = "longhorn"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = var.useLonghorn ? "true" : "false"
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  allow_volume_expansion = true
  parameters = {
    numberOfReplicas    = "3"
    staleReplicaTimeout = "2880" # 48 hours in minutes
    fromBackup          = ""
  }
}


# ---------------------------------------------------------------------------------------------------------------------
#  Prepare cluster to deploy Rancher Management UI
# ---------------------------------------------------------------------------------------------------------------------

# Create rancher-installer service account
resource "kubernetes_service_account" "rancher_installer" {
  metadata {
    name      = "rancher-intaller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

# Bind rancher-intall service account to cluster-admin
resource "kubernetes_cluster_role_binding" "rancher_installer_admin" {
  metadata {
    name = "${kubernetes_service_account.rancher_installer.metadata[0].name}-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rancher_installer.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_job" "install_cert_manager_crds" {
  depends_on = [kubernetes_namespace.rancher_ui_ns, kubernetes_namespace.rancher_cert_ns]

  metadata {
    name      = "install-certmanager-crds"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = "bitnami/kubectl:1.18.16"
          command = ["kubectl", "apply", "-f", "https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml"]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.rancher_installer.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
  wait_for_completion = true
}
