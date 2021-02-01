# Specifies the libvirt host where terraform will deploy the machines on.
# Using local system here
provider_uri = "qemu:///system"

# Specifies where all disks will be stored on the machine.
storage_pool = "/home/kevin/cluster1/pools/"

# The cluster name is used as a prefix for all domains and disks to allow multiple clusters on the same node.
cluster_name = "test"

# Specifies the network the machines are attached to.
network_name = "myvirt_net"

# Specfies the source disk for all machines
source_image = "./modules/template.qcow2"

masterHosts = [
  {
    ip       = "192.168.180.120"
    public_ip = ""
    mac      = "52:54:00:6c:3c:78"
    hostname = "Master1"
  },
  {
    ip       = "192.168.180.121"
    public_ip = ""
    mac      = "52:54:00:6c:3c:79"
    hostname = "Master2"
  },
  {
    ip       = "192.168.180.122"
    public_ip = ""
    mac      = "52:54:00:6c:3c:7a"
    hostname = "Master3"
  }
]

workerHosts = [
  {
    ip        = "192.168.180.123"
    public_ip = "10.17.69.17"
    mac       = "52:54:00:6c:3c:7b"
    hostname  = "Worker1"
  },
  {
    ip        = "192.168.180.124"
    public_ip = "10.17.69.18"
    mac       = "52:54:00:6c:3c:7c"
    hostname  = "Worker2"
  },
  {
    ip        = "192.168.180.125"
    public_ip = "10.17.69.19"
    mac       = "52:54:00:6c:3c:7d"
    hostname  = "Worker3"
  },
  {
    ip        = "192.168.180.126"
    public_ip = "10.17.69.21"
    mac       = "52:54:00:6c:3c:7e"
    hostname  = "Worker4"
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

# (Optional) Specifies the number of CPU the Workstation will receive
ws_cpu = 1

# (Optional) Specifies the number of memory the Workstation will receive
ws_memory = 4096
