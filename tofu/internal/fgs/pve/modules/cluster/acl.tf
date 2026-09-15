resource "proxmox_acl" "tofu" {
  user_id   = proxmox_virtual_environment_user.operator.user_id
  role_id   = proxmox_virtual_environment_role.devops_operator.role_id
  path      = "/"
  propagate = true
}
