resource "proxmox_virtual_environment_user" "tofu" {
  comment  = "Managed by OpenTofu for automation"
  user_id  = "tofu@pve"
  password = var.tofu_user_password
  enabled  = true
  groups = [
    proxmox_virtual_environment_group.devops.group_id,
  ]
}

resource "proxmox_virtual_environment_user_token" "tofu" {
  comment               = "Managed by OpenTofu for automation"
  token_name            = "devops-operator-token"
  user_id               = proxmox_virtual_environment_user.tofu.user_id
  privileges_separation = true
}
