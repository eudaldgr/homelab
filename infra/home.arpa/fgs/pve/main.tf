resource "proxmox_vm_qemu" "container-host" {
  provider    = proxmox.pve[var.proxmox_nodes[0].name]
  name        = "container-host-01"
  target_node = var.proxmox_nodes[0].name
  vmid        = 1000
  bios        = "ovmf"
  onboot      = true
  clone       = local.os_template
  full_clone  = true
  memory      = 32768
  balloon     = 0
  cpu {
    cores = 6
    type  = "host"
  }
  scsihw      = "virtio-scsi-single"
  tags        = "microOS,podman"
  agent       = 1
  ciuser      = local.ciuser
  ciupgrade   = true
  sshkeys     = file(var.ssh_public_key_path)
  ipconfig0    = "ip=dhcp,ip6=auto"
  ipconfig1    = ""
  ipconfig2    = ""
  network {
    id      = 0
    model   = "virtio"
    macaddr = "BC:24:14:34:CD:01"
    bridge  = "vmbr1"
    tag     = 90
    firewall = true
  }
  network {
    id      = 1
    model   = "virtio"
    macaddr = "BC:24:14:34:CD:11"
    bridge  = "vmbr1"
    tag     = 20
    firewall = true
  }
  network {
    id      = 2
    model   = "virtio"
    macaddr = "BC:24:14:34:CD:12"
    bridge  = "vmbr1"
    tag     = 99
    firewall = true
  }
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = local.storage
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          discard    = true
          emulatessd = true
          size       = "64G"
          replicate  = true
          storage    = local.storage
        }
      }
    }
  }
  serial {
    id   = 0
    type = "socket"
  }
}

# resource "proxmox_vm_qemu" "k3s-servers" {
#   for_each = { for node in var.proxmox_nodes : node.name => node }
#   provider = proxmox.pve[each.key]

#   name        = "k3s-server-0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#   target_node = each.key
#   vmid        = local.id_servers + index(var.proxmox_nodes[*].name, each.key)
#   bios        = "ovmf"
#   onboot      = true
#   clone       = local.os_template
#   full_clone  = true
#   memory      = 4096
#   balloon     = 0
#   cpu {
#     cores = 2
#     type  = "host"
#   }
#   scsihw      = "virtio-scsi-single"
#   tags        = "microos,k3s,server"
#   agent       = 1
#   # cloudinit
#   ciuser    = local.ciuser
#   ciupgrade = true
#   sshkeys   = file(var.ssh_public_key_path)
#   ipconfig0  = "ip=dhcp,ip6=auto"
#   network {
#     id      = 0
#     model   = "virtio"
#     macaddr = "BC:24:11:12:AB:0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#     bridge  = "vmbr1"
#     tag     = 20
#     firewall = true
#   }
#   disks {
#     ide {
#       ide0 {
#         cloudinit {
#           storage = local.storage
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           discard    = true
#           emulatessd = true
#           size       = "64G"
#           replicate  = true
#           storage    = local.storage
#         }
#       }
#     }
#   }
#   serial {
#     id   = 0
#     type = "socket"
#   }
# }

# resource "proxmox_vm_qemu" "k3s-longhorns" {
#   for_each = { for node in var.proxmox_nodes : node.name => node }
#   provider = proxmox.pve[each.key]

#   name        = "k3s-longhorn-0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#   target_node = each.key
#   vmid        = local.id_longhorns + index(var.proxmox_nodes[*].name, each.key)
#   bios        = "ovmf"
#   onboot      = true
#   clone       = local.os_template
#   full_clone  = true
#   memory      = 8192
#   balloon     = 0
#   cpu {
#     cores = 2
#     type  = "host"
#   }
#   scsihw      = "virtio-scsi-single"
#   tags        = "microos,k3s,longhorn"
#   agent       = 1
#   # cloudinit
#   ciuser    = local.ciuser
#   ciupgrade = true
#   sshkeys   = file(var.ssh_public_key_path)
#   ipconfig0  = "ip=dhcp,ip6=auto"
#   network {
#     id      = 0
#     model   = "virtio"
#     macaddr = "BC:24:11:56:EF:0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#     bridge  = "vmbr1"
#     tag     = 20
#     firewall = true
#   }
#   disks {
#     ide {
#       ide0 {
#         cloudinit {
#           storage = local.storage
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           discard    = true
#           emulatessd = true
#           size       = "40G"
#           replicate  = true
#           storage    = local.storage
#         }
#       }
#     }
#   }
#   serial {
#     id   = 0
#     type = "socket"
#   }
#   pcis {
#     pci0 {
#       mapping {
#         mapping_id  = "SSD"
#         pcie        = true
#         primary_gpu = false
#         rombar      = true
#       }
#     }
#   }
# }

# resource "proxmox_vm_qemu" "k3s-agents" {
#   for_each = { for node in var.proxmox_nodes : node.name => node }
#   provider = proxmox.pve[each.key]

#   name        = "k3s-agent-0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#   target_node = each.key
#   vmid        = local.id_agents + index(var.proxmox_nodes[*].name, each.key)
#   bios        = "ovmf"
#   onboot      = true
#   clone       = local.os_template
#   full_clone  = true
#   memory      = 8192 #[32768, 16384][index(var.proxmox_nodes[*].name, each.key)]
#   balloon     = 0
#   cpu {
#     cores = 2 #[6, 4][index(var.proxmox_nodes[*].name, each.key)]
#     type  = "host"
#   }
#   scsihw      = "virtio-scsi-single"
#   tags        = "microos,k3s,agent"
#   agent       = 1
#   # cloudinit
#   ciuser    = local.ciuser
#   ciupgrade = true
#   sshkeys   = file(var.ssh_public_key_path)
#   ipconfig0  = "ip=dhcp,ip6=auto"
#   ipconfig1  = "ip=dhcp,ip6=auto"
#   network {
#     id      = 0
#     model   = "virtio"
#     macaddr = "BC:24:11:34:CD:0${index(var.proxmox_nodes[*].name, each.key) + 1}"
#     bridge  = "vmbr1"
#     tag     = 20
#     firewall = true
#   }
#   network {
#     id      = 1
#     model   = "virtio"
#     macaddr = "BC:24:11:34:CD:1${index(var.proxmox_nodes[*].name, each.key) + 1}"
#     bridge  = "vmbr1"
#     tag     = 10
#     firewall = true
#   }
#   disks {
#     ide {
#       ide0 {
#         cloudinit {
#           storage = local.storage
#         }
#       }
#     }
#     scsi {
#       scsi0 {
#         disk {
#           discard    = true
#           emulatessd = true
#           size       = "64G"
#           replicate  = true
#           storage    = local.storage
#         }
#       }
#     }
#   }
#   serial {
#     id   = 0
#     type = "socket"
#   }
#   pcis {
#     pci0 {
#       mapping {
#         mapping_id  = "iGPU"
#         pcie        = true
#         primary_gpu = true
#         rombar      = true
#       }
#     }
#   }
# }
