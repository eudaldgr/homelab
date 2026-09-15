# Proxmox API configuration
proxmox = {
  endpoint  = "https://10.1.90.111:8006"
}

# Cluster nodes configuration
nodes = {
  pve01 = {}
  pve02 = {}
  pve03 = {}
}

# Talos cluster configuration
talos = {
  talos_version = "v1.14.0"
}

talos_controlplanes = {
  ctrl-01 = {
    node   = "pve01"
    vmid   = 2001
    cores  = 12
    memory = 49152
    disk   = 160
    mac    = "bc:24:11:00:00:01"
  }
  ctrl-02 = {
    node   = "pve02"
    vmid   = 2002
    cores  = 6
    memory = 20480
    disk   = 160
    mac    = "bc:24:11:00:00:02"
  }
  ctrl-03 = {
    node   = "pve03"
    vmid   = 2003
    cores  = 4
    memory = 12288
    disk   = 160
    mac    = "bc:24:11:00:00:03"
  }
}
