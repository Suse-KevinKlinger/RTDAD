#
# Libvirt related variables
#
variable "provider_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "cluster_name" {
  description = "The cluster name is used as a prefix for all domains and pools"
  type        = string
  default     = "test"
}

variable "storage_pool" {
  description = "Specifies where the pools (place where the disks) will be stored."
  type        = string
  default     = "default"
}

variable "network_name" {
  description = "Name of the network, the machines will be attached to. This must be an already existing virtual network."
  type        = string
  default     = ""
}

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now. Specific node images have preference over this value"
  type        = string
  default     = ""
}

# CaaSP master node related variables

variable "master_cpu" {
  description = "Number of CPUs the master nodes will receive"
  type        = number
  default     = 4
}

variable "master_memory" {
  description = "Amount of memory the master nodes will receive"
  type        = number
  default     = 8192
}

variable "masterHosts" {
  description = ""
  type = list(object({
    ip       = string
    mac      = string
    hostname = string
  }))
  default = []
}

# CaaSP worker node related variables

variable "worker_cpu" {
  description = "Number of CPUs the worker nodes will receive"
  type        = number
  default     = 4
}

variable "worker_memory" {
  description = "Amount of memory the worker nodes will receive"
  type        = number
  default     = 32768
}

variable "workerHosts" {
  description = ""
  type = list(object({
    ip       = string
    mac      = string
    hostname = string
  }))
  default = []
}

# Workstation related variables
variable "ws_cpu" {
  description = "Number of CPUs the LoadBalancer nodes will receive"
  type        = number
  default     = 4
}

variable "ws_memory" {
  description = "Amount of memory the LoadBalancer nodes will receive"
  type        = number
  default     = 16384
}

variable "nodes" {
  description = ""
  type = list(object({
    public_ip  = string
    private_ip = string
    hostname   = string
    roles      = list(string)
    user       = string
    ssh_key    = string
  }))
  default = []
}
