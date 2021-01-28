#
# Libvirt related variables
#
variable "provider_uri" {
  description = "URI to connect with the qemu-service."
  default     = "qemu:///system"
}

variable "cluster_name" {
  description = "The cluster name is used as a prefix for all domains and pools"
  type	      = string
  default     = "test"
}

variable "storage_pool" {
  description = "libvirt storage pool name for VM disks"
  type        = string
  default     = "default"
}

variable "network_name" {
  description = "Already existing virtual network name. If it's not provided a new one will be created"
  type        = string
  default     = ""
}

variable "source_image" {
  description = "Source image used to boot the machines (qcow2 format). It's possible to specify the path to a local (relative to the machine running the terraform command) image or a remote one. Remote images have to be specified using HTTP(S) urls for now. Specific node images have preference over this value"
  type        = string
  default     = ""
}

variable "machine_name" {
  description = "Name of the machine"
  type        = string
  default     = ""
}

variable "cpu" {
  description = "Defines the number of CPU the machine will receive" 
  type        = number
  default     = 4
}

variable "memory" {
  description = "Defines the amount of RAM the machine will receive"
  type        = number
  default     = 16384
}

variable "mac_address" {
  description = "MAC address the machine is supposed to receive"
  type        = string
  default     = ""
}

variable "user_data_path" {
  description = "Location of the cloud init script to be used"
  type        = string
  default     = ""
}

variable "ip_address" {
  description = "IP address the machine is supposed to receive"
  type        = string
  default     = ""
}

variable "public_key" {
  description = "Public ssh key created by keys module"
  type = string
  default = ""
}

variable "ssh_key_file" {
  description = "Private ssh key to connect to machine"
  type = string
  default = ""
}

variable "kubeconfig" {
  description = "Kubeconfig to access the RKE cluster"
  type = string
  default = ""
}