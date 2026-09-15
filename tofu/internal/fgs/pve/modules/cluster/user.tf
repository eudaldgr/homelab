# OpenTofu
resource "proxmox_virtual_environment_user" "operator" {
  depends_on = [proxmox_virtual_environment_role.devops_operator]

  user_id = "tofu@pve"
  comment = "Managed by OpenTofu for automation"
}

resource "proxmox_user_token" "tofu" {
  comment               = "Managed by OpenTofu for automation"
  token_name            = "devops-operator-token"
  user_id               = proxmox_virtual_environment_user.operator.user_id
  privileges_separation = false
}
