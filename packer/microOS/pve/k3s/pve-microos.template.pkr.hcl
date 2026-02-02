/*
 * Creates a MicroOS template for Proxmox VE cloud-init ready using Packer.
 */

source "proxmox-clone" "microOS" {
}

build {
  name = "pve-microOS"

  dynamic "source" {
    for_each = var.proxmox_nodes
    labels   = ["proxmox-clone.microOS"]
    content {
      node                     = source.value.name
      proxmox_url              = "https://${source.value.host}:${source.value.port}/api2/json"
      insecure_skip_tls_verify = true
      username                 = source.value.username
      token                    = source.value.token

      clone_vm                 = "microOS"
      full_clone               = true
      vm_id                    = 9011
      vm_name                  = "microOS-k3s"
      tags                     = "microos;k3s"
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
      vga {
        type                   = "serial0"
      }
      network_adapters {
        model                  = "virtio"
        bridge                 = "vmbr1"
        vlan_tag               = 20
        firewall                = true
      }
      serials = [
        "socket"
      ]
      qemu_agent               = true
      scsi_controller          = "virtio-scsi-pci"
      template_description     = "MicroOS + k3s, generated on ${timestamp()}"
      cloud_init               = true
      cloud_init_storage_pool  = source.value.local_storage
      cloud_init_disk_type     = "scsi"
      additional_iso_files {
        cd_content = {
          "meta-data" = templatefile("${abspath(path.root)}/config/meta-data.pkrtpl.hcl", {
                                        instance_id = "microOS-k3s"
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
      ssh_username             = "root"
      ssh_private_key_file      = var.ssh_private_key_file
    }
  }

  # Install packages
  provisioner "shell" {
    pause_before      = "15s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }

  # Configure system
  provisioner "shell" {
    pause_before      = "15s"
    inline            = [local.configure_system]
    expect_disconnect = true
  }

  # Do house-keeping
  provisioner "shell" {
    pause_before = "15s"
    inline       = [local.clean_up]
  }
}
