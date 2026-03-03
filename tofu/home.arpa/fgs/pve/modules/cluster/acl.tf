resource "proxmox_virtual_environment_role" "devops_operator" {
  role_id = "devops-operator"

  privileges = [
    "Sys.Audit",
    "Sys.Modify",
    "Datastore.Audit",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Mapping.Use",
    "SDN.Use",
    "VM.Audit",
    "VM.Allocate",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.CPU",
    "VM.Config.Cloudinit",
    "VM.Config.Disk",
    "VM.Config.HWType",
    "VM.Config.Memory",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.PowerMgmt",
  ]
}

resource "proxmox_virtual_environment_acl" "devops_group_role" {
  group_id = proxmox_virtual_environment_group.devops.group_id
  role_id  = proxmox_virtual_environment_role.devops_operator.role_id

  path      = "/"
  propagate = true
}

resource "proxmox_virtual_environment_acl" "tofu_token_role" {
  token_id = proxmox_virtual_environment_user_token.tofu.id
  role_id  = proxmox_virtual_environment_role.devops_operator.role_id

  path      = "/"
  propagate = true
}
