variable "namespace" {
  description = "The namespace in which the cluster is going to be deployed"
  type        = string
  default     = "di"
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

variable "useLonghorn" {
  description = "Determines if Longhorn should be used as the default storage"
  type        = bool
  default     = true
}