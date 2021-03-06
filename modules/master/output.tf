output "ip" {
  description = "IP of the master node"
  value       = var.ip_address
}

output "hostname" {
  description = "IP of the master node"
  value       = var.machine_name
}

output "user" {
  description = "IP of the master node"
  value       = "root"
}

output "roles" {
  description = "Kubernetes roles of the master node"
  value       = ["etcd", "controlplane"]
}
