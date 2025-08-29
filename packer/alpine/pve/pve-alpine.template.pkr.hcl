/*
 * Creates an Alpine Linux cloud image template for Proxmox
 * Uses official Alpine Linux cloud image with cloud-init support
 */

source "proxmox-iso" "alpineOS" {
}

build {
  name = "pve-alpineOS-cloud"

  dynamic "source" {
    for_each = var.proxmox_nodes
    labels   = ["proxmox-iso.alpineOS"]
    content {
      node                     = source.value.name
      proxmox_url              = "https://${source.value.host}:${source.value.port}/api2/json"
      insecure_skip_tls_verify = true
      username                 = source.value.username
      token                    = source.value.token

      vm_id                    = 9020
      vm_name                  = "alpineOS"
      tags                     = "alpineOS"
      memory                   = 1024
      cores                    = 1
      cpu_type                 = "host"
      os                       = "l26"
      bios                     = "ovmf"
      efi_config {
        efi_storage_pool        = source.value.storage
        efi_type                = "4m"
        pre_enrolled_keys      = false
      }
      machine                  = "q35"
      boot_command             = [
        // Login as root
        "<wait10>", "root", "<enter>", "<wait3>",
        
        // Setup networking with DHCP
        "setup-interfaces -a", "<enter>", "<wait5>",
        "rc-service networking restart", "<enter>", "<wait10>",
        
        // Setup community repository
        "setup-apkrepos -c", "<enter>", "<wait5>",
        "<enter>", "<wait5>",

        // Install utilities
        "apk update", "<enter>", "<wait5>",
        "apk add qemu-guest-agent wget qemu-img doas", "<enter>", "<wait10>",

        // Enable qemu-guest-agent
        "rc-service qemu-guest-agent start", "<enter>", "<wait5>",
        
        // Set doas for user and password
        "adduser -D ${local.user}", "<enter>", "<wait3>",
        "echo '${local.user}:${var.password}' | chpasswd", "<enter>", "<wait3>",
        "adduser ${local.user} wheel", "<enter>", "<wait3>",
        "echo 'permit nopass :wheel' >> /etc/doas.conf", "<enter>", "<wait3>",

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
        firewall                = true
      }
      disks {
        disk_size              = "256M"
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
      template_description     = "Alpine Linux ${var.alpine_version} Cloud Image - generated on ${timestamp()}"
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
      ssh_username             = local.user
      ssh_password             = var.password
      ssh_private_key_file      = var.ssh_private_key_file
    }
  }

  # Download the Alpine Linux cloud image
  provisioner "shell" {
    inline = [
      "echo 'Downloading image...'",
      "${local.download_image} ${local.alpine_cloud_img_url} -O /tmp/${local.alpine_cloud_img_name} >/dev/null 2>&1",
    ]
  }

  # Convert the image to raw format and write it to disk
  provisioner "shell" {
    inline            = [local.write_image]
  }

  # Copy ssh keys to the image
  provisioner "shell" {
    inline            = [local.copy_ssh_keys]
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
    pause_before      = "15s"
    inline            = [local.clean_up]
  }
}