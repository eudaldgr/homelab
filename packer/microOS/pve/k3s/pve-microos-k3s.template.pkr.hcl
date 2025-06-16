/*
 * Creates a MicroOS template for Proxmox VE cloud-init ready using Packer.
 */

source "proxmox-iso" "microOS" {
}

build {
  name = "microOS-k3s"

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

      vm_id                    = 9010
      vm_name                  = "microOS-k3s"
      tags                     = "microos;k3s"
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

        // Stop tiny-cloud-early, main and final services
        "rc-service tiny-cloud-early stop", "<enter>", "<wait3>",
        "rc-service tiny-cloud-main  stop", "<enter>", "<wait3>",
        "rc-service tiny-cloud-final stop", "<enter>", "<wait3>",

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
      template_description     = "MicroOS + k3s, generated on ${timestamp()}"
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
          "meta-data" = templatefile("${abspath(path.root)}/config/meta-data.pkrtpl.hcl", {
                                        instance_id = "microOS-k3s"
                                    })
          "user-data" = templatefile("${abspath(path.root)}/config/user-data.pkrtpl.hcl", {
                                        user    = var.user
                                        ssh_key = file("${abspath(path.cwd)}/ssh/packer.pub")
                                    })
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
      "echo 'Downloading MicroOS image...'",
      "${local.download_image} ${local.microos_img_url}          -O /tmp/${local.microos_img_name}        >/dev/null 2>&1",
      "${local.download_image} ${local.microos_img_checksum_url} -O /tmp/${local.microos_img_name}.sha256 >/dev/null 2>&1",
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