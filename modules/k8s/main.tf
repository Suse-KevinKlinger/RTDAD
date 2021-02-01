# ---------------------------------------------------------------------------------------------------------------------
#  Create the namespace to be used
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "di" {
  metadata {
    name = var.namespace
  }
}

# ---------------------------------------------------------------------------------------------------------------------
#  Create the ceph secrets
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_secret" "ceph-admin-secret" {
  depends_on = [kubernetes_namespace.di]

  metadata {
    name      = "ceph-admin-secret"
    namespace = var.namespace
  }

  data = {
    key = "QVFBYnM3dGZBQUFBQUJBQSs1SVIvaUNWd0Jrcko0YXIrWXUyTmc9PQo="
  }

  type = "kubernetes.io/rbd"
}

resource "kubernetes_secret" "ceph-user-secret" {
  depends_on = [kubernetes_namespace.di]

  metadata {
    name      = "ceph-user-secret"
    namespace = var.namespace
  }

  data = {
    key = "QVFBZHM3dGZBQUFBQUJBQVA3UkxrU1NqOVVTNWEzZDJDcmhYbEE9PQo="
  }

  type = "kubernetes.io/rbd"
}

# ---------------------------------------------------------------------------------------------------------------------
#  Create storage class
# ---------------------------------------------------------------------------------------------------------------------

resource "kubernetes_storage_class" "distorage" {
  metadata {
    name = "distorage"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
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
