# Bridge interfaces
resource "proxmox_virtual_environment_network_linux_bridge" "vmbr0" {
  for_each   = var.nodes
  node_name  = each.key
  name       = "vmbr0"
  vlan_aware = true
  ports      = ["nic0"]
}

resource "proxmox_virtual_environment_network_linux_bridge" "vmbr1" {
  for_each   = var.nodes
  node_name  = each.key
  name       = "vmbr1"
  vlan_aware = true
  ports      = ["nic1"]
}

# VLANs
resource "proxmox_virtual_environment_network_linux_vlan" "vmbr0-91" {
  for_each  = var.nodes
  node_name = each.key
  name      = "vmbr0.91"
  comment   = "ceph"
  interface = "vmbr0"
  vlan      = 91
  address   = "${each.value.ceph_address}/24"

  depends_on = [
    proxmox_virtual_environment_network_linux_bridge.vmbr0,
  ]
}

resource "proxmox_virtual_environment_network_linux_vlan" "vmbr1-30" {
  for_each  = var.nodes
  node_name = each.key
  name      = "vmbr1.30"
  comment   = "storage"
  interface = "vmbr1"
  vlan      = 30
  address   = "${each.value.storage_address}/24"

  depends_on = [
    proxmox_virtual_environment_network_linux_bridge.vmbr1,
  ]
}

resource "proxmox_virtual_environment_network_linux_vlan" "vmbr1-90" {
  for_each  = var.nodes
  node_name = each.key
  name      = "vmbr1.90"
  comment   = "lab"
  interface = "vmbr1"
  vlan      = 90
  address   = "${each.value.address}/24"
  gateway   = each.value.gateway

  depends_on = [
    proxmox_virtual_environment_network_linux_bridge.vmbr1,
  ]
}
