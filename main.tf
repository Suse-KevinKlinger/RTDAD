
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
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

 # Store the id private key in a file.
resource "local_file" "id_rsa" {
  depends_on = [ tls_private_key.id ]
  filename = "modules/keys/id_rsa"
  file_permission = "0600"
  sensitive_content = tls_private_key.id.private_key_pem
}

 # Store the id public key in a file.
resource "local_file" "id_rsa_pub" {
  content  = tls_private_key.id.public_key_openssh
  filename = "modules/keys/id_rsa.pub"
  depends_on = [ tls_private_key.id ]
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Master nodes
# ---------------------------------------------------------------------------------------------------------------------

module "master" {
  depends_on = [tls_private_key.id]

  count          = var.noMasters
  source         = "./modules/master/"
  machine_name   = "Master${count.index}"
  network_name   = var.network_name
  mac_address    = var.masterMacs[count.index]
  ip_address     = var.masterIPs[count.index]
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

  count          = var.noWorkers
  source         = "./modules/worker/"
  machine_name   = "Workerr${count.index}"
  network_name   = var.network_name
  mac_address    = var.workerMacs[count.index]
  ip_address     = var.workerIPs[count.index]
  cluster_name   = var.cluster_name
  user_data_path = "${path.module}/cloud_init.cfg"
  storage_pool   = var.storage_pool
  cpu            = var.worker_cpu
  memory         = var.worker_memory
  ssh_key_file   = tls_private_key.id.private_key_pem
  public_key     = tls_private_key.id.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Workstation
# ---------------------------------------------------------------------------------------------------------------------

module "workstation" {
  depends_on = [tls_private_key.id]

  source         = "./modules/workstation/"
  machine_name   = "Workstation"
  network_name   = var.network_name
  mac_address    = "52:54:00:6c:3c:77"
  ip_address     = "192.168.180.129"
  cluster_name   = var.cluster_name
  user_data_path = "${path.module}/modules/workstation/cloud_init.cfg"
  storage_pool   = var.storage_pool
  cpu            = var.ws_cpu
  memory         = var.ws_memory
  ssh_key_file   = tls_private_key.id.private_key_pem
  public_key     = tls_private_key.id.public_key_openssh
}

# ---------------------------------------------------------------------------------------------------------------------
#  Deploy RKE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  masterList = [
    for instance in flatten([[module.master]]) : {
      public_ip = instance.public_ip
      hostname  = instance.hostname
      user      = instance.user
      roles     = instance.roles
      ssh_key   = tls_private_key.id.private_key_pem
    }
  ]
  workerList = [
    for instance in flatten([[module.worker]]) : {
      public_ip = instance.public_ip
      hostname  = instance.hostname
      user      = instance.user
      roles     = instance.roles
      ssh_key   = tls_private_key.id.private_key_pem
    }
  ]
}

module "rancher" {
  depends_on = [module.master, module.worker, module.workstation, local.masterList, local.workerList]
  source     = "./modules/rke/"

  rke_nodes = concat(local.masterList,local.workerList)

  rke = {
    cluster_name = "rancher_test"
    dind = false
    kubernetes_version = "v1.18.6-rancher1-1"
  }


  providers = {
    rke = rke.rkeProvider
  }
}

