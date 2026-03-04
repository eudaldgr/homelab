# OpenTofu
resource "proxmox_virtual_environment_user" "tofu" {
  user_id = "tofu@pve"
  comment = "Managed by OpenTofu for automation"

  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.devops_operator.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "tofu" {
  comment               = "Managed by OpenTofu for automation"
  token_name            = "devops-operator-token"
  user_id               = proxmox_virtual_environment_user.tofu.user_id
  privileges_separation = true
}

# Proxmox-csi
resource "proxmox_virtual_environment_user" "kubernetes-csi" {
  user_id = "kubernetes-csi@pve"
  comment = "User for Proxmox CSI Plugin"

  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.csi.role_id
  }
}

resource "proxmox_virtual_environment_user_token" "kubernetes-csi-token" {
  comment               = "Token for Proxmox CSI Plugin"
  token_name            = "csi"
  user_id               = proxmox_virtual_environment_user.kubernetes-csi.user_id
  privileges_separation = false
}
