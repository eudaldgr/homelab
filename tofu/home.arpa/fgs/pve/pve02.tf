resource "proxmox_vm_qemu" "k3s-server-02" {
  provider = proxmox.pve02

  name               = "k3s-server-02"
  target_node        = var.proxmox_nodes[1].name
  vmid               = local.id_servers
  bios               = "ovmf"
  start_at_node_boot = true
  clone              = local.k3s_template
  full_clone         = true
  memory             = 4096
  balloon            = 0
  skip_ipv6          = true
  cpu {
    cores = 2
    type  = "host"
  }
  scsihw = "virtio-scsi-single"
  tags   = "microos,k3s,server"
  agent  = 1
  # cloudinit
  ciuser    = local.ciuser
  ciupgrade = true
  sshkeys   = file(var.ssh_public_key_path)
  ipconfig0 = "ip=dhcp,ip6=auto"
  network {
    id       = 0
    model    = "virtio"
    macaddr  = "BC:24:11:12:AB:02"
    bridge   = "vmbr1"
    tag      = 20
    firewall = false
  }
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.proxmox_nodes[1].storage
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
          storage    = var.proxmox_nodes[1].storage
        }
      }
    }
  }
  serial {
    id   = 0
    type = "socket"
  }
}

resource "proxmox_vm_qemu" "k3s-agent-02" {
  provider = proxmox.pve02

  name               = "k3s-agent-02"
  target_node        = var.proxmox_nodes[1].name
  vmid               = local.id_agents
  bios               = "ovmf"
  start_at_node_boot = true
  clone              = local.k3s_template
  full_clone         = true
  memory             = 24576
  balloon            = 0
  skip_ipv6          = true
  cpu {
    cores = 4
    type  = "host"
  }
  scsihw = "virtio-scsi-single"
  tags   = "microos,k3s,agent"
  agent  = 1
  # cloudinit
  ciuser    = local.ciuser
  ciupgrade = true
  sshkeys   = file(var.ssh_public_key_path)
  ipconfig0 = "ip=dhcp,ip6=auto"
  network {
    id       = 0
    model    = "virtio"
    macaddr  = "BC:24:11:34:CD:02"
    bridge   = "vmbr1"
    tag      = 20
    firewall = false
  }
  disks {
    ide {
      ide0 {
        cloudinit {
          storage = var.proxmox_nodes[1].storage
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
          storage    = var.proxmox_nodes[1].storage
        }
      }
    }
  }
  serial {
    id   = 0
    type = "socket"
  }
  pcis {
    pci0 {
      mapping {
        mapping_id  = "iGPU"
        pcie        = true
        primary_gpu = true
        rombar      = true
      }
    }
    pci1 {
      mapping {
        mapping_id  = "SSD"
        pcie        = true
        primary_gpu = false
        rombar      = true
      }
    }
  }
}
