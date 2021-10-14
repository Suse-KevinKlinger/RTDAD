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

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now. Specific node images have preference over this value"
  type        = string
  default     = ""
}

# RKE master node related variables

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

# RKE worker node related variables

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

variable "longhorn_disk_size" {
  description = "Specifies the size (in Bytes) of the disk to be used for Longhorn storage"
  type        = number
  default     = 220000000000
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
variable "workstation" {
  description = ""
  type = object({
    ip       = string
    hostname = string
    cpu      = number
    memory   = number
  })
  default = {
    ip       = ""
    hostname = "Workstation"
    cpu      = 4
    memory   = 16384
  }
}

# RKE related variables
variable "nodes" {
  description = ""
  type = list(object({
    private_ip = string
    hostname   = string
    roles      = list(string)
    user       = string
    ssh_key    = string
  }))
  default = []
}

variable "ceph_admin_secret" {
  description = "The key that can be used to access the SES storage as admin user"
  type        = string
  default     = ""
}

variable "ceph_user_secret" {
  description = "The key that can be used to access the SES storage as desired user"
  type        = string
  default     = ""
}

variable "registry_ip" {
  description = "IP address of the private container registry to be used for SAP DI"
  type        = string
  default     = ""
}

variable "registry_fqdn" {
  description = "FQDN of the private container registry to be used for SAP DI"
  type        = string
  default     = ""
}

variable "registry_hostname" {
  description = "Hostname of the private container registry to be used for SAP DI"
  type        = string
  default     = ""
}

variable "default_route_ip" {
  description = "The IP of the default route gateway to be used"
  type    = string
  default = ""
}

// TODO check if needed when there is a RKE2 terraform provider

# variable "rancherUI_address" {
#   description = "FQDN of where the Rancher UI should be reached at"
#   type        = string
#   default     = ""
# }

# variable "rancherUI_version" {
#   description = "Desired version of the Rancher UI to be deployed"
#   type        = string
#   default     = "v2.5.6"
# }

# variable "cert_manager_version" {
#   description = "Desired version of the Cert-Manager to be deployed"
#   type        = string
#   default     = "v1.0.4"
# }
# variable "rke_Version" {
#   description = "Specifies the RKE version and by this the Kubernetes version to be used"
#   type        = string
#   default     = "v1.18.16-rancher1-1"
# }
#
#
# # Kubernetes related variables
# variable "k8s_namespace" {
#   description = "The Kubernetes namespace that will be created and be used for secrets, storageClasses, etc."
#   type        = string
#   default     = "di"
# }