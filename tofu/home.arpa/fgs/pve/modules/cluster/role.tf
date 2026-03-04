# OpenTofu
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
    "VM.GuestAgent.Audit",
    "VM.GuestAgent.Unrestricted",
    "VM.PowerMgmt",
  ]
}

# Proxmox-csi
resource "proxmox_virtual_environment_role" "csi" {
  role_id = "csi"

  privileges = [
    "Sys.Audit",
    "VM.Audit",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit"
  ]
}
