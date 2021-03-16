variable "rancherUI_address" {
  description = "FQDN of where the Rancher UI should be reached at"
  type        = string
  default     = ""
}

variable "rancherUI_version" {
  description = "Desired version of the Rancher UI to be deployed"
  type        = string
  default     = "v2.5.6"
}

variable "cert_manager_version" {
  description = "Desired version of the Cert-Manager to be deployed"
  type        = string
  default     = "v1.0.4"
}
