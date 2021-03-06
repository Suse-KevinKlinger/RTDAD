# Create a new RKE cluster using config yaml
resource "rke_cluster" "foo" {
  cluster_name = var.rke.cluster_name
  dind         = var.rke.dind

  dynamic nodes {
    for_each = var.rke_nodes
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.hostname
      user              = nodes.value.user
      role              = nodes.value.roles
      ssh_key           = nodes.value.ssh_key
    }
  }
  upgrade_strategy {
    drain                        = false
    max_unavailable_controlplane = "1"
    max_unavailable_worker       = "10%"
  }

  kubernetes_version = var.rke.kubernetes_version
}

