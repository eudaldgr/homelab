# Proxmox API configuration
proxmox = {
  endpoint = "https://10.1.90.111:8006"
}

# Cluster nodes configuration
nodes = {
  pve01 = {
    address         = "10.1.90.111",
    gateway         = "10.1.90.1",
    igpu_mapping = {
      id           = "8086:9bc8"
      iommu_group  = 0
      path         = "0000:00:02.0"
      subsystem_id = "1028:09a8"
    }
    rook_ceph_mapping = {
      id           = "8086:a382"
      iommu_group  = 5
      path         = "0000:00:17.0"
      subsystem_id = "1028:09a8"
    }
  }
  pve02 = {
    address         = "10.1.90.112",
    gateway         = "10.1.90.1",
    igpu_mapping = {
      id           = "8086:3e92"
      iommu_group  = 0
      path         = "0000:00:02.0"
      subsystem_id = "103c:859c"
    }
    rook_ceph_mapping = {
      id           = "8086:a352"
      iommu_group  = 5
      path         = "0000:00:17.0"
      subsystem_id = "103c:859c"
    }
  }
  pve03 = {
    address         = "10.1.90.113",
    gateway         = "10.1.90.1",
    igpu_mapping = {
      id           = "8086:5912"
      iommu_group  = 0
      path         = "0000:00:02.0"
      subsystem_id = "1028:07a3"
    }
    rook_ceph_mapping = {
      id           = "8086:a282"
      iommu_group  = 4
      path         = "0000:00:17.0"
      subsystem_id = "1028:07a3"
    }
  }
}

# DNS configuration
dns = {
  domain  = "lan.eudald.gr"
  servers = ["10.1.90.1"]
}
