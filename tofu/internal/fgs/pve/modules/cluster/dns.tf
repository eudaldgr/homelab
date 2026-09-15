resource "proxmox_virtual_environment_dns" "nodes" {
  for_each  = var.nodes
  node_name = each.key
  domain    = var.dns.domain
  servers   = var.dns.servers
}
