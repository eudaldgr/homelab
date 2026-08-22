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

  stop_on_destroy                      = false
  purge_on_destroy                     = false
  delete_unreferenced_disks_on_destroy = false

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
    floating  = 0
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
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
    file_id      = proxmox_download_file.talos_gpu.id
    discard      = "on"
    ssd          = true
  }

  operating_system {
    type = "l26"
  }

  network_device {
    model       = "virtio"
    bridge      = "vmbr1"
    mac_address = each.value.mac
    trunks      = "30;90"
  }

  agent {
    enabled = true

    wait_for_ip {
      disabled = true
    }
  }

  hostpci {
    device  = "hostpci0"
    mapping = "iGPU"
    pcie    = true
    rombar  = true
    xvga    = true
  }

  hostpci {
    device  = "hostpci1"
    mapping = "RookCeph"
    pcie    = true
    rombar  = false
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [disk[0].file_id]
  }

  depends_on = [
    proxmox_download_file.talos_gpu,
  ]
}
