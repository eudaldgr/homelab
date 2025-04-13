/*
 * Creates a UmbrelOS template for Proxmox
 */
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = list(object({
    name        = string
    host        = string
    port        = number
    tls         = bool
    username    = string
    password    = string
    token       = string
    storage     = string
    iso_storage = string
  }))
}

variable "alpine_version" {
  type    = string
  default = "3.21.3"
}

variable "umbrelos_version" {
  type    = string
  default = "1.4.0"
}

locals {
  alpine_iso_file     = "alpine-virt-${var.alpine_version}-x86_64.iso"
  alpine_iso_url      = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/${local.alpine_iso_file}"
  alpine_iso_checksum = "file:${local.alpine_iso_url}.sha256"

  umbrelos_base_url          = "https://download.umbrel.com/release/${var.umbrelos_version}"
  umbrelos_img_name          = "umbrelos-amd64.img"
  umbrelos_img_url           = "${local.umbrelos_base_url}/${local.umbrelos_img_name}.xz"
  umbrelos_img_checksum_name = "SHA256SUMS"
  umbrelos_img_checksum_url  = "${local.umbrelos_base_url}/${local.umbrelos_img_checksum_name}"
}

source "proxmox-iso" "umbrelOS" {
  node                     = var.proxmox_nodes[0].name
  proxmox_url              = "https://${var.proxmox_nodes[0].host}:${var.proxmox_nodes[0].port}/api2/json"
  insecure_skip_tls_verify = true
  username                 = var.proxmox_nodes[0].username
  # password                 = var.proxmox_nodes[0].password
  token                    = var.proxmox_nodes[0].token

  vm_name                  = "umbrelOS-${var.umbrelos_version}"
  vm_id                    = 92140
  tags                     = "umbrel;bitcoin"
  memory                   = 16384
  cores                    = 4
  cpu_type                 = "host"
  os                       = "l26"
  bios                     = "ovmf"
  efi_config {
    efi_storage_pool       = var.proxmox_nodes[0].storage
    efi_type               = "4m"
    pre_enrolled_keys      = false
  }
  machine                  = "q35"
  # tpm_config {
  #   tpm_version            = "v2.0"
  #   tpm_storage_pool       = var.proxmox_nodes[0].storage
  # }
  boot_command             = [
    // Login as root
    "root<enter><wait10>",

    // Set root password
    "echo 'root:changeme' | chpasswd<enter><wait3>",
    
    // Setup networking with DHCP
    "setup-interfaces -a<enter><wait5>",
    "rc-service networking restart<enter><wait10>",
    
    // Setup community repository
    "setup-apkrepos -c<enter><wait5>",
    "<enter><wait5>",

    // Install and enable qemu-guest-agent
    "apk update<enter><wait5>",
    "apk add qemu-guest-agent<enter><wait10>",
    "rc-service qemu-guest-agent start<enter><wait5>",

    // Install and configure SSH
    "apk add openssh<enter><wait10>",
    "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config<enter>",
    "rc-service sshd start<enter><wait5>"
  ]
  vga {
    type                   = "serial0"
  }
  network_adapters {
    model                  = "virtio"
    bridge                 = "vmbr1"
    vlan_tag               = 20
    firewall               = true
  }
  disks {
    disk_size              = "32G"
    storage_pool           = var.proxmox_nodes[0].storage
    type                   = "scsi"
    ssd                    = true
    discard                = true
  }
  serials = [
    "socket"
  ]
  scsi_controller          = "virtio-scsi-pci"
  template_description     = "umbrelOS, generated on ${timestamp()}"
  boot_iso {
    type                   = "scsi"
    //iso_file               = "${var.proxmox_nodes[0].iso_storage}:iso/${local.alpine_iso_file}"
    iso_url                = local.alpine_iso_url
    iso_storage_pool       = var.proxmox_nodes[0].iso_storage
    unmount                = true
    iso_checksum           = local.alpine_iso_checksum
  }
  ssh_username             = "root"
  ssh_password             = "changeme"
}

build {
  sources = ["source.proxmox-iso.umbrelOS"]

  provisioner "shell" {
    inline = [
      "apk update",
      "apk add wget xz",
      
      "echo 'Downloading MicroOS image...'",
      "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only ${local.umbrelos_img_url}          -O /tmp/${local.umbrelos_img_name}.xz",
      "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only ${local.umbrelos_img_checksum_url} -O /tmp/${local.umbrelos_img_checksum_name}",
      
      "echo 'Verifying download...'",
      "cd /tmp",
      "grep ${local.umbrelos_img_name}.xz ${local.umbrelos_img_checksum_name} | sha256sum -c",
      
      "echo 'Writing compressed image directly to disk...'",
      "xzcat /tmp/${local.umbrelos_img_name}.xz | dd bs=4M of=/dev/sda",
      
      "echo 'Image successfully written to disk'",
      "sync"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Template preparation complete'"
    ]
  }
}