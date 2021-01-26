# declare custom pools
resource "libvirt_pool" "workstation" {
 name = "${var.cluster_name}_${var.machine_name}"
 type = "dir"
 path = "${var.storage_pool}/${var.cluster_name}_${var.machine_name}_pool/"
}

# adapt the build number 
resource "libvirt_volume" "osDisk" {
  name   = "${var.machine_name}_image.qcow2"
  pool   = libvirt_pool.workstation.name
  source = "${path.module}/../template.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file(var.user_data_path)
  vars = {
    HOSTNAME    = var.machine_name
    PUBLICKEY   = var.public_key
    IPADDR      = var.ip_address
  }
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
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

# Copies the private ssh key file to /root/.ssh/sshkey
  provisioner "file" {
    source      = "${path.module}/sshkey"
    destination = "/root/.ssh/sshkey"
    connection {
      type     = "ssh"
      host     = var.ip_address
      private_key = var.ssh_key_file
    }
  }


# Copies the script to distribute the certificate to all machines
  provisioner "file" {
    source      = "${path.module}/distributor.sh"
    destination = "/home/distributor.sh"
    connection {
      type     = "ssh"
      host     = var.ip_address
      private_key = var.ssh_key_file
    }
  }


# Copies the storageClass to be created for SAP DI
  provisioner "file" {
    source      = "${path.module}/di.tar.gz"
    destination = "/home/di.tar.gz"
    connection {
      type     = "ssh"
      host     = var.ip_address
      private_key = var.ssh_key_file
    }
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
}

 
