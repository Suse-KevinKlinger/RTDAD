
# instance the provider
provider "libvirt" {
  uri = var.provider_uri
}
/*
provider "kubernetes" {
  host                   = module.rancher.api_server_url
  client_certificate     = module.rancher.client_cert
  client_key             = module.rancher.client_key
  cluster_ca_certificate = module.rancher.ca_crt
}

provider "helm" {
  kubernetes {
    host                   = module.rancher.api_server_url
    client_certificate     = module.rancher.client_cert
    client_key             = module.rancher.client_key
    cluster_ca_certificate = module.rancher.ca_crt
  }
}*/

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

  count               = length(var.masterHosts)
  source              = "./modules/master/"
  machine_name        = var.masterHosts[count.index].hostname
  mac_address         = var.masterHosts[count.index].mac
  ip_address          = var.masterHosts[count.index].ip
  cluster_name        = var.cluster_name
  user_data_path      = "${path.module}/modules/master/cloud_init.cfg"
  storage_pool        = var.storage_pool
  cpu                 = var.master_cpu
  memory              = var.master_memory
  ssh_key_file        = tls_private_key.id.private_key_pem
  public_key          = tls_private_key.id.public_key_openssh
  salt_master_address = var.workstation.ip
  registry_ip         = var.registry_ip
  registry_fqdn       = var.registry_fqdn
  registry_hostname   = var.registry_hostname
  rke2server          = var.masterHosts[0].ip
  default_route_ip    = var.default_route_ip
}

# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Worker nodes
# ---------------------------------------------------------------------------------------------------------------------

module "worker" {
  depends_on = [tls_private_key.id]

  count               = length(var.workerHosts)
  source              = "./modules/worker/"
  machine_name        = var.workerHosts[count.index].hostname
  mac_address         = var.workerHosts[count.index].mac
  ip_address          = var.workerHosts[count.index].ip
  cluster_name        = var.cluster_name
  user_data_path      = "${path.module}/modules/worker/cloud_init.cfg"
  storage_pool        = var.storage_pool
  cpu                 = var.worker_cpu
  memory              = var.worker_memory
  ssh_key_file        = tls_private_key.id.private_key_pem
  public_key          = tls_private_key.id.public_key_openssh
  salt_master_address = var.workstation.ip
  registry_ip         = var.registry_ip
  registry_fqdn       = var.registry_fqdn
  registry_hostname   = var.registry_hostname
  rke2server          = var.masterHosts[0].ip
  default_route_ip    = var.default_route_ip
}

# ---------------------------------------------------------------------------------------------------------------------
#  Prepare Kubernetes for SAP DI Deployment
# ---------------------------------------------------------------------------------------------------------------------
/*
module "kubernetes" {
  depends_on = [module.master, module.worker]

  source            = "./modules/k8s"
  namespace         = var.k8s_namespace
  ceph_admin_secret = var.ceph_admin_secret
  ceph_user_secret  = var.ceph_user_secret
}

module "helm" {
  depends_on = [module.kubernetes]

  source               = "./modules/rancher"
  rancherUI_address    = var.rancherUI_address
  rancherUI_version    = var.rancherUI_version
  cert_manager_version = var.cert_manager_version
}
*/
# ---------------------------------------------------------------------------------------------------------------------
#  Spin up Workstation
# ---------------------------------------------------------------------------------------------------------------------

module "workstation" {
  source            = "./modules/workstation/"
  machine_name      = var.workstation.hostname
  ip_address        = var.workstation.ip
  cluster_name      = var.cluster_name
  user_data_path    = "${path.module}/modules/workstation/cloud_init.cfg"
  storage_pool      = var.storage_pool
  cpu               = var.workstation.cpu
  memory            = var.workstation.memory
  ssh_key_file      = tls_private_key.id.private_key_pem
  public_key        = tls_private_key.id.public_key_openssh
  kubeconfig        = ""
  registry_ip       = var.registry_ip
  registry_fqdn     = var.registry_fqdn
  registry_hostname = var.registry_hostname
  default_route_ip    = var.default_route_ip
}
