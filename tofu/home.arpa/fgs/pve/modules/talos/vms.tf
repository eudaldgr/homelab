resource "proxmox_virtual_environment_vm" "talos" {
  for_each = local.all_nodes

  node_name = each.value.node
  vm_id     = each.value.vmid
  name      = each.key
  tags      = ["talos", each.value.role]

  bios          = "ovmf"
  machine       = "q35"
  on_boot       = true
  scsi_hardware = "virtio-scsi-pci"

  stop_on_destroy                      = true
  purge_on_destroy                     = true
  delete_unreferenced_disks_on_destroy = true

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
    floating  = 0
  }

  dynamic "serial_device" {
    for_each = each.value.igpu ? [1] : []
    content {
      device = "socket"
    }
  }

  dynamic "vga" {
    for_each = each.value.igpu ? [1] : []
    content {
      type = "serial0"
    }
  }

  efi_disk {
    datastore_id = var.nodes[each.value.node].local_storage
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    interface    = "scsi0"
    size         = each.value.disk
    datastore_id = var.nodes[each.value.node].local_storage
    file_format  = "raw"
    file_id      = each.value.igpu ? proxmox_download_file.talos_gpu.id : proxmox_download_file.talos_std.id
    discard      = "on"
    ssd          = true
  }

  operating_system {
    type = "l26"
  }

  network_device {
    model       = "virtio"
    bridge      = "vmbr1"
    vlan_id     = 20
    mac_address = each.value.mac
  }

  agent {
    enabled = true

    wait_for_ip {
      disabled = true
    }
  }

  dynamic "hostpci" {
    for_each = each.value.igpu ? ["iGPU"] : []
    content {
      device  = "hostpci0"
      mapping = hostpci.value
      pcie    = true
      rombar  = true
      xvga    = true
    }
  }

  lifecycle {
    ignore_changes = [disk[0].file_id]
  }

  depends_on = [
    proxmox_download_file.talos_std,
    proxmox_download_file.talos_gpu,
  ]
}
