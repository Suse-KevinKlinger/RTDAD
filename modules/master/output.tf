output "rancher_nodes" {
    value = {
    #public_ip  = libvirt_domain.master.network_interface[0].addresses[0]
    public_ip  = var.ip_address
    #hostname   = libvirt_domain.master.network_interface[0].hostname
    hostname   = var.machine_name
    user       = "root"
    roles      = ["etcd", "master"]
    ssh_key    = var.ssh_key_file
    }
    sensitive = true
}


