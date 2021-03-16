terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.2.1"
    }
  }
}

