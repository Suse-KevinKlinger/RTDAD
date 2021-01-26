output "public_ip" {
  description = "IP of the worker node"
  value       = var.ip_address
}

output "hostname" {
  description = "IP of the worker node"
  value       = var.machine_name
}

output "user" {
  description = "IP of the worker node"
  value       = "root"
}

output "roles" {
  description = "Kubernetes roles of the worker node"
  value       = ["worker"]
}
