resource "proxmox_virtual_environment_time" "main" {
  for_each  = var.nodes
  node_name = each.key
  time_zone = var.time_zone
}
