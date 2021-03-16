variable "rke_nodes" {
  type = list(object({
    ip       = string
    hostname = string
    roles    = list(string)
    user     = string
    ssh_key  = string
  }))
  description = "Node info to install RKE cluster"
}

variable "rke" {
  type = object({
    cluster_name       = string
    dind               = bool
    kubernetes_version = string
  })
  default = {
    cluster_name       = "rancher-server"
    dind               = false
    kubernetes_version = ""
  }
  description = "RKE configuration"
}
