# declare custom pools
resource "libvirt_pool" "worker" {
  name = "${var.cluster_name}_${var.machine_name}"
  type = "dir"
  path = "${var.storage_pool}/${var.cluster_name}_${var.machine_name}_pool/"
}

# adapt the build number 
resource "libvirt_volume" "osDisk" {
  name   = "${var.machine_name}_image.qcow2"
  pool   = libvirt_pool.worker.name
  source = "${path.module}/../template.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "dataDisk" {
  name   = "${var.machine_name}_data.qcow2"
  pool   = libvirt_pool.worker.name
  format = "qcow2"
  size   = 120000000000
}

resource "libvirt_volume" "longhornDisk" {
  name   = "${var.machine_name}_longhorn.qcow2"
  pool   = libvirt_pool.worker.name
  format = "qcow2"
  size   = var.longhorn_disk_size
}


data "template_file" "user_data" {
  template = file(var.user_data_path)
  vars = {
    HOSTNAME       = var.machine_name
    PUBLICKEY      = var.public_key
    IPADDR         = var.ip_address
    SALTMASTERADDR = var.salt_master_address
    REGIP          = var.registry_ip
    REGFQDN        = var.registry_fqdn
    REGHN          = var.registry_hostname
  }
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "${var.machine_name}_commoninit.iso"
  user_data = data.template_file.user_data.rendered
  pool      = libvirt_pool.worker.name
}

# Create the machine
resource "libvirt_domain" "worker" {
  name   = "${var.cluster_name}_${var.machine_name}"
  memory = var.memory
  vcpu   = var.cpu

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    bridge = "br0"
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
  disk {
    volume_id = libvirt_volume.dataDisk.id
  }
  disk {
    volume_id = libvirt_volume.longhornDisk.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null"
    ]

    connection {
      type        = "ssh"
      host        = var.ip_address
      private_key = var.ssh_key_file
    }
  }
}
