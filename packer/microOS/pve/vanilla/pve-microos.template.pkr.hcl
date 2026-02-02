/*
 * Creates a MicroOS template for Proxmox VE cloud-init ready using Packer.
 */

source "proxmox-iso" "microOS" {
}

build {
  name = "pve-microOS"

  dynamic "source" {
    for_each = var.proxmox_nodes
    labels   = ["proxmox-iso.microOS"]
    content {
      node                     = source.value.name
      proxmox_url              = "https://${source.value.host}:${source.value.port}/api2/json"
      insecure_skip_tls_verify = true
      username                 = source.value.username
      token                    = source.value.token

      vm_id                    = 9010
      vm_name                  = "microOS"
      tags                     = "microos;vanilla"
      memory                   = 2048
      ballooning_minimum       = 0
      cores                    = 1
      cpu_type                 = "host"
      os                       = "l26"
      bios                     = "ovmf"
      efi_config {
        efi_storage_pool        = source.value.local_storage
        efi_type                = "4m"
        pre_enrolled_keys      = false
      }
      machine                  = "q35"
      tpm_config {
        tpm_version            = "v2.0"
        tpm_storage_pool       = source.value.local_storage
      }
      boot_command             = [
        // Login as root
        "<wait10>", "root", "<enter>", "<wait3>",

        // Add ssh key for root
        "mkdir -p /root/.ssh", "<enter>", "<wait3>",
        "echo '${replace(file(var.ssh_public_key_file), "\n", "")}' > /root/.ssh/authorized_keys", "<enter>", "<wait3>",
        "chmod 700 /root/.ssh", "<enter>", "<wait3>",
        "chmod 600 /root/.ssh/authorized_keys", "<enter>", "<wait3>",
        
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

        // Install SSH
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
        disk_size              = "24G"
        storage_pool           = source.value.local_storage
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
      cloud_init_storage_pool  = source.value.local_storage
      cloud_init_disk_type     = "scsi"
      boot_iso {
        type                   = "ide"
        index                  = 0
        iso_url                = local.alpine_iso_url
        iso_storage_pool       = source.value.iso_storage
        unmount                = true
        iso_checksum           = local.alpine_iso_checksum
      }
      additional_iso_files {
        cd_content = {
          "meta-data" = templatefile("${abspath(path.root)}/config/meta-data.pkrtpl.hcl", {
                                        instance_id = "microOS"
                                    })
          "user-data" = templatefile("${abspath(path.root)}/config/user-data.pkrtpl.hcl", {
                                        ssh_key = file(var.ssh_public_key_file)
                                    })
        }
        cd_label                 = "cidata"
        iso_storage_pool         = source.value.iso_storage
        type                     = "ide"
        index                    = 1
        unmount                  = true
      }
      ssh_username              = "root"
      ssh_private_key_file       = var.ssh_private_key_file
    }
  }

  # Download the MicroOS image
  provisioner "shell" {
    inline = [
      "echo 'Downloading MicroOS image...'",
      "${local.download_image} ${local.microos_x86_img_url}          -O /tmp/${local.microos_x86_img_name}        >/dev/null 2>&1",
      "${local.download_image} ${local.microos_x86_img_checksum_url} -O /tmp/${local.microos_x86_img_name}.sha256 >/dev/null 2>&1",
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