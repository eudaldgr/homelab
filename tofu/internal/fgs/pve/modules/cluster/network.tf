resource "proxmox_network_linux_bridge" "vmbr1" {
  for_each   = var.nodes
  node_name  = each.key
  name       = "vmbr1"
  vlan_aware = true
  ports      = ["nic1"]
  mtu        = 9000
}

resource "proxmox_network_linux_vlan" "vmbr1-90" {
  for_each  = var.nodes
  node_name = each.key
  name      = "vmbr1.90"
  comment   = "lab"
  interface = "vmbr1"
  vlan      = 90
  address   = "${each.value.address}/24"
  mtu       = 9000
  gateway   = each.value.gateway

  depends_on = [
    proxmox_network_linux_bridge.vmbr1,
  ]
}
