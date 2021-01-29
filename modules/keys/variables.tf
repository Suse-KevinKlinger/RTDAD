variable "fqdn" {
  description = "FQDN for the machine"
  type        = string
  default     = "changeme.example.com"
}

variable "ip_addresses" {
  description = "value"
  type        = list(string)
  default     = []
}

variable "dns_names" {
  description = "value"
  type        = list(string)
  default     = []
}