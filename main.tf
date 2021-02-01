
# instance the provider
provider "libvirt" {
  uri = var.provider_uri
}

provider "rke" {
  alias    = "rkeProvider"
  log_file = "rke_debug.log"
}

# ---------------------------------------------------------------------------------------------------------------------
#  CREATE SSH KEYS
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "id" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Store the id private key in a file.
resource "local_file" "id_rsa" {
  depends_on        = [tls_private_key.id]
  filename          = "modules/keys/id_rsa"
  file_permission   = "0600"
  sensitive_content = tls_private_key.id.private_key_pem
}

# Store the id public key in a file.
resource "local_file" "id_rsa_pub" {
  content    = tls_private_key.id.public_key_openssh
  filename   = "modules/keys/id_rsa.pub"
  depends_on = [tls_private_key.id]
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Master nodes
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  depends_on = [tls_private_key.id]

  count          = length(var.masterHosts)
  source         = "./modules/master/"
  machine_name   = var.masterHosts[count.index].hostname
  network_name   = var.network_name
  mac_address    = var.masterHosts[count.index].mac
  ip_address     = var.masterHosts[count.index].ip
  public_ip      = var.masterHosts[count.index].public_ip
  cluster_name   = var.cluster_name
  user_data_path = "${path.module}/cloud_init.cfg"
  storage_pool   = var.storage_pool
  cpu            = var.master_cpu
  memory         = var.master_memory
  ssh_key_file   = tls_private_key.id.private_key_pem
  public_key     = tls_private_key.id.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Worker nodes
# ---------------------------------------------------------------------------------------------------------------------

module "worker" {
  depends_on = [tls_private_key.id]

  count          = length(var.workerHosts)
  source         = "./modules/worker/"
  machine_name   = var.workerHosts[count.index].hostname
  network_name   = var.network_name
  mac_address    = var.workerHosts[count.index].mac
  ip_address     = var.workerHosts[count.index].ip
  public_ip      = var.workerHosts[count.index].public_ip
  cluster_name   = var.cluster_name
  user_data_path = "${path.module}/cloud_init.cfg"
  storage_pool   = var.storage_pool
  cpu            = var.worker_cpu
  memory         = var.worker_memory
  ssh_key_file   = tls_private_key.id.private_key_pem
  public_key     = tls_private_key.id.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
#  Deploy RKE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  masterList = flatten([
    for host in module.master : {
      public_ip = host.ip
      hostname  = host.hostname
      roles     = host.roles
      ssh_key   = tls_private_key.id.private_key_pem
      user      = host.user
    }
  ])
  workerList = flatten([
    for host in module.worker : {
      public_ip = host.ip
      hostname  = host.hostname
      roles     = host.roles
      ssh_key   = tls_private_key.id.private_key_pem
      user      = host.user
    }
  ])
}

module "rancher" {
  depends_on = [module.master, module.worker, local.masterList, local.workerList]
  source     = "./modules/rke/"

  rke_nodes = concat(local.masterList, local.workerList)

  rke = {
    cluster_name       = "rancher_test"
    dind               = false
    kubernetes_version = "v1.18.6-rancher1-1"
  }


  providers = {
    rke = rke.rkeProvider
  }
}

// Write kubeconfig to Terraform host
resource "local_file" "kubeconfig" {
  content    = module.rancher.kubeconfig
  filename   = "kubeconfig"
  depends_on = [module.rancher]
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Workstation
# ---------------------------------------------------------------------------------------------------------------------

module "workstation" {
  depends_on = [module.rancher]

  source         = "./modules/workstation/"
  machine_name   = "Workstation"
  network_name   = var.network_name
  mac_address    = "52:54:00:6c:3c:77"
  ip_address     = "192.168.180.119"
  cluster_name   = var.cluster_name
  user_data_path = "${path.module}/modules/workstation/cloud_init.cfg"
  storage_pool   = var.storage_pool
  cpu            = var.ws_cpu
  memory         = var.ws_memory
  ssh_key_file   = tls_private_key.id.private_key_pem
  public_key     = tls_private_key.id.public_key_openssh
  kubeconfig     = module.rancher.kubeconfig
}