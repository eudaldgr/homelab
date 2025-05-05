/*
 * Creates a MicroOS template for Proxmox VE cloud-init ready using Packer.
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

variable "packages_to_install" {
  type    = list(string)
  description = "List of packages to install on the MicroOS template"
  default = []
}

variable "ssh_public_key_file" {
  type        = string
  description = "List of SSH public keys to add to the root user via cloud-init"
  default     = "./ssh/packer.pub"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the SSH private key file"
  default     = "./ssh/packer"
}

variable "user" {
  type        = string
  description = "User for cloud-init"
  default     = "packer"
}

variable "alpine_version" {
  type    = string
  default = "3.21.3"
}

locals {
  alpine_iso_file     = "alpine-virt-${var.alpine_version}-x86_64.iso"
  alpine_iso_url      = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/${local.alpine_iso_file}"
  alpine_iso_checksum = "file:${local.alpine_iso_url}.sha256"

  microos_img_name         = "openSUSE-MicroOS.x86_64-ContainerHost-OpenStack-Cloud.qcow2"
  microos_img_url          = "https://download.opensuse.org/tumbleweed/appliances/${local.microos_img_name}"
  microos_img_checksum_url = "${local.microos_img_url}.sha256"

  needed_packages = join(" ", concat([
    "restorecond",
    "policycoreutils",
    "policycoreutils-python-utils",
    "setools-console",
    "audit",
    "bind-utils",
    "wireguard-tools",
    "fuse",
    "open-iscsi",
    "nfs-client",
    "xfsprogs",
    "cryptsetup",
    "lvm2",
    "git",
    "cifs-utils",
    "bash-completion",
    "mtr",
    "tcpdump",
    "rebootmgr",
    "podman"
  ], var.packages_to_install))

  download_image = "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only"

  checksum_image = <<-EOT
    set -ex
    echo 'Verifying MicroOS image checksum...'
    cd /tmp
    grep ${local.microos_img_name} ${local.microos_img_name}.sha256 | sha256sum -c
  EOT

  write_image = <<-EOT
    set -ex
    echo 'MicroOS image loaded, writing to disk...'
    doas qemu-img dd -f qcow2 -O raw bs=4M if=/tmp/${local.microos_img_name} of=/dev/sda
    echo 'Image successfully written to disk, rebooting...'
    sleep 1 && doas sync && doas reboot
  EOT

  wait_for_cloudinit = <<-EOT
    set -ex
    sleep 30
    while pgrep -f transactional-update >/dev/null; do
        echo 'Waiting cloudinit transactional-update to finish...'
        sleep 10
    done
  EOT
  
  install_packages = <<-EOT
    set -ex
    echo 'First reboot successful, installing needed packages and doing some configurations...'
    sudo timedatectl set-timezone Europe/Madrid
    sudo transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && sudo udevadm settle && sudo reboot
  EOT
  
  clean_up = <<-EOT
    set -ex
    echo 'Second reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    sudo rm -rf /etc/ssh/ssh_host_*
    echo 'Make sure to use NetworkManager'
    sudo touch /etc/NetworkManager/NetworkManager.conf
    sudo userdel -r ${var.user} || true
    sleep 1 && sudo udevadm settle
  EOT

  # Cloud-init configuration
  cloud_init_meta_data = <<-EOT
    instance-id: microOS
  EOT

  cloud_init_user_data = <<-EOT
    #cloud-config
    ssh_pwauth: false
    users:
      - name: ${var.user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, wheel
        ssh_authorized_keys:
          - ${file("${var.ssh_public_key_file}")}
    write_files:
      - path: /etc/sysctl.d/90-rke2-net.conf
        content: |
          net.ipv4.conf.all.forwarding=1
          net.ipv6.conf.all.forwarding=1
      - path: /tmp/install
        content: |
          zypper refresh
          zypper dup -y
          zypper install -y qemu-guest-agent
          systemctl enable --now qemu-guest-agent
          sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
          grub2-mkconfig > /boot/grub2/grub.cfg
      - path: /etc/cloud/cloud.cfg.d/99-default-user.cfg
        content: |
          #cloud-config
          system_info:
            default_user:
              sudo: ALL=(ALL) NOPASSWD:ALL
              groups: users, wheel
              shell: /bin/bash
      - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
        content: |
          #cloud-config
          network:
            config: disabled
      - path: /etc/cloud/cloud.cfg.d/98-use-networkmanager.cfg
        content: |
          #cloud-config
          system_info:
            network:
              renderers: ['network-manager']
    growpart:
      mode: auto
      devices: ['/', '/var']
    runcmd:
      - transactional-update run sh -c "$(cat /tmp/install)" && reboot
  EOT
}

// MicroOS
source "proxmox-iso" "microOS" {
}

build {
  dynamic "source" {
    for_each = var.proxmox_nodes
    labels   = ["proxmox-iso.microOS"]
    content {
      node                     = source.value.name
      proxmox_url              = "https://${source.value.host}:${source.value.port}/api2/json"
      insecure_skip_tls_verify = true
      username                 = source.value.username
      # password                 = source.value.password
      token                    = source.value.token

      vm_id                    = 9011
      vm_name                  = "microOS"
      tags                     = "microos"
      memory                   = 4096
      cores                    = 1
      cpu_type                 = "host"
      os                       = "l26"
      bios                     = "ovmf"
      efi_config {
        efi_storage_pool       = source.value.storage
        efi_type               = "4m"
        pre_enrolled_keys      = false
      }
      machine                  = "q35"
      tpm_config {
        tpm_version            = "v2.0"
        tpm_storage_pool       = source.value.storage
      }
      boot_command             = [
        // Login as root
        "<wait10>", "root", "<enter>", "<wait3>",

        // Set doas for user
        "adduser ${var.user} wheel", "<enter>", "<wait3>",
        "echo 'permit nopass :wheel' >> /etc/doas.conf", "<enter>", "<wait3>",
        
        // Setup networking with DHCP
        "setup-interfaces -a", "<enter>", "<wait5>",
        "rc-service networking restart", "<enter>", "<wait10>",
        
        // Setup community repository
        "setup-apkrepos -c", "<enter>", "<wait5>",
        "<enter>", "<wait5>",

        // Install and enable qemu-guest-agent
        "apk update", "<enter>", "<wait5>",
        "apk add qemu-guest-agent", "<enter>", "<wait10>",
        "rc-service qemu-guest-agent start", "<enter>", "<wait5>",

        // Install utilities
        "apk add wget qemu-img", "<enter>", "<wait10>",

        // Install and configure SSH
        "apk add openssh", "<enter>", "<wait10>",
        "rc-service sshd restart", "<enter>", "<wait5>"
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
        disk_size              = "40G"
        storage_pool           = source.value.storage
        type                   = "scsi"
        ssd                    = true
        discard                = true
      }
      serials = [
        "socket"
      ]
      qemu_agent               = true
      scsi_controller          = "virtio-scsi-pci"
      template_description     = "MicroOS, generated on ${timestamp()}"
      cloud_init               = true
      cloud_init_storage_pool  = source.value.storage
      cloud_init_disk_type     = "scsi"
      boot_iso {
        type                   = "ide"
        index                  = 0
        # iso_file               = "${source.value.iso_storage}:iso/${local.alpine_iso_file}"
        iso_url                = local.alpine_iso_url
        iso_storage_pool       = source.value.iso_storage
        unmount                = true
        iso_checksum           = local.alpine_iso_checksum
      }
      # Add cloud-init ISO with SSH keys
      additional_iso_files {
        # cd_files                 = ["vendor-data"]
        cd_content = {
          "meta-data" = local.cloud_init_meta_data
          "user-data" = local.cloud_init_user_data
        }
        cd_label                 = "cidata"
        iso_storage_pool         = source.value.iso_storage
        type                     = "ide"
        index                    = 1
        unmount                  = true
        # iso_checksum             = "none"
      }
      ssh_username              = var.user
      # ssh_password              = var.password
      ssh_private_key_file      = var.ssh_private_key_file
    }
  }

  # Download the MicroOS image
  provisioner "shell" {
    inline = [
      "${local.download_image} ${local.microos_img_url}          -O /tmp/${local.microos_img_name}        >/dev/null",
      "${local.download_image} ${local.microos_img_checksum_url} -O /tmp/${local.microos_img_name}.sha256 >/dev/null",
    ]
  }

  # Verify the download
  provisioner "shell" {
    inline = [local.checksum_image]
  }

  # Convert the MicroOS image to raw format and write it to disk
  provisioner "shell" {
    inline            = [local.write_image]
    expect_disconnect = true
  }

  # Wait for cloudinit runcmd to finish
  provisioner "shell" {
    pause_before      = "15s"
    inline            = [local.wait_for_cloudinit]
    expect_disconnect = true
  }

  # Install packages
  provisioner "shell" {
    pause_before      = "15s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }
  
  # Do house-keeping
  provisioner "shell" {
    pause_before = "15s"
    inline       = [local.clean_up]
  }
}