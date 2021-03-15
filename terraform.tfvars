# Specifies the libvirt host where terraform will deploy the machines on.
# Using local system here
provider_uri = "qemu:///system"

# Specifies where all disks will be stored on the machine.
storage_pool = "/home/kevin/cluster1/pools/"

# The cluster name is used as a prefix for all domains and disks to allow multiple clusters on the same node.
cluster_name = "test"

# Specfies the source disk for all machines
source_image = "./modules/template.qcow2"

masterHosts = [
  {
    ip       = "10.17.69.25"
    mac      = "52:54:00:6c:3c:78"
    hostname = "Master1"
  },
  {
    ip       = "10.17.69.26"
    mac      = "52:54:00:6c:3c:79"
    hostname = "Master2"
  },
  {
    ip       = "10.17.69.27"
    mac      = "52:54:00:6c:3c:7a"
    hostname = "Master3"
  }
]

workerHosts = [
  {
    ip       = "10.17.69.17"
    mac      = "52:54:00:6c:3c:7b"
    hostname = "Worker1"
  },
  {
    ip       = "10.17.69.18"
    mac      = "52:54:00:6c:3c:7c"
    hostname = "Worker2"
  },
  {
    ip       = "10.17.69.19"
    mac      = "52:54:00:6c:3c:7d"
    hostname = "Worker3"
  },
  {
    ip       = "10.17.69.21"
    mac      = "52:54:00:6c:3c:7e"
    hostname = "Worker4"
  }
]

# (Optional) Specifies the number of CPU the CaaSP Master nodes will receive
master_cpu = 4

# (Optional) Specifies the amount of memory the CaaSP Master nodes will receive
master_memory = 16384

# (Optional) Specifies the number of CPU the CaaSP Worker nodes will receive
worker_cpu = 4

# (Optional) Specifies the amount of memory the CaaSP Worker nodes will receive
worker_memory = 32768

workstation = {
  ip       = "10.17.69.29"
  hostname = "Workstation"
  cpu      = 1
  memory   = 4096
}

registry_ip       = "10.17.69.28"
registry_fqdn     = "Harbor-Registry.example.com"
registry_hostname = "Harbor-Registry"

rancherUI_address = "test.example.com"

# (Optional) If a Ceph storage is used, the admin secret can be initialized here so K8s will create those on deployment
ceph_admin_secret = "QVFBYnM3dGZBQUFBQUJBQSs1SVIvaUNWd0Jrcko0YXIrWXUyTmc9PQo="

# (Optional) If a Ceph storage is used, the user secret can be initialized here so K8s will create those on deployment
ceph_user_secret = "QVFBZHM3dGZBQUFBQUJBQVA3UkxrU1NqOVVTNWEzZDJDcmhYbEE9PQo="
