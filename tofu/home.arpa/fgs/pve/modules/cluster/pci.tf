resource "proxmox_virtual_environment_hardware_mapping_pci" "igpu" {
  name = "iGPU"
  map = [
    for key, val in var.nodes : {
      id           = val.igpu_mapping.id
      iommu_group  = val.igpu_mapping.iommu_group
      node         = key
      path         = val.igpu_mapping.path
      subsystem_id = val.igpu_mapping.subsystem_id
    }
    if val.igpu_mapping != null
  ]
}

resource "proxmox_virtual_environment_hardware_mapping_pci" "rook_ceph" {
  name = "RookCeph"
  map = [
    for key, val in var.nodes : {
      id           = val.rook_ceph_mapping.id
      iommu_group  = val.rook_ceph_mapping.iommu_group
      node         = key
      path         = val.rook_ceph_mapping.path
      subsystem_id = val.rook_ceph_mapping.subsystem_id
    }
    if try(val.rook_ceph_mapping, null) != null
  ]
}
