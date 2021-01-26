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

noMasters = 1

masterMacs = ["52:54:00:6c:3c:78","52:54:00:6c:3c:79","52:54:00:6c:3c:80"]

masterIPs = ["192.168.180.120","192.168.180.121","192.168.180.122"]


noWorkers = 1

workerMacs = ["52:54:00:6c:3c:81","52:54:00:6c:3c:82","52:54:00:6c:3c:83","52:54:00:6c:3c:84"]

workerIPs = ["192.168.180.123","192.168.180.124","192.168.180.125", "192.168.180.126"]

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
