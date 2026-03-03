resource "proxmox_virtual_environment_group" "devops" {
  comment  = "Managed by OpenTofu for automation"
  group_id = "devops"
}
