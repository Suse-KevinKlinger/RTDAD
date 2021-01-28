# Create a custom pool
resource "libvirt_pool" "workstation" {
 name = "${var.cluster_name}_${var.machine_name}"
 type = "dir"
 path = "${var.storage_pool}/${var.cluster_name}_${var.machine_name}_pool/"
}

# Create a osDisk based on a given template 
resource "libvirt_volume" "osDisk" {
  name   = "${var.machine_name}_image.qcow2"
  pool   = libvirt_pool.workstation.name
  source = "${path.module}/../template.qcow2"
  format = "qcow2"
}

# Parse the given cloudInit script
data "template_file" "user_data" {
  template = file(var.user_data_path)
  vars = {
    HOSTNAME    = var.machine_name
    PUBLICKEY   = var.public_key
    IPADDR      = var.ip_address
  }
}

# Create a CloudInit-disk to be used by the workstation
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.machine_name}_commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  pool           = libvirt_pool.workstation.name
}

# Create the machine
resource "libvirt_domain" "workstation" {
  name   = "${var.cluster_name}_${var.machine_name}"
  memory = var.memory
  vcpu   = var.cpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name = var.network_name
    mac = var.mac_address
    hostname = var.machine_name
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  
  disk {
    volume_id = libvirt_volume.osDisk.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  # Writes the kubeconfig file created by the RKE provider to access the RKE cluster
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null",
      "echo '${var.kubeconfig}' > /root/.kube/config"
    ]
    connection {
      type     = "ssh"
      host     = var.ip_address
      private_key = var.ssh_key_file
    }
  }
}

 
