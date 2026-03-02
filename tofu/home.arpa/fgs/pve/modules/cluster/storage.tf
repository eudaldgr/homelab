resource "proxmox_virtual_environment_storage_directory" "local" {
  id    = "local"
  path  = "/var/lib/vz"
  nodes = []

  content = ["backup", "import", "iso", "vztmpl"]
  shared  = false
  disable = true
}

resource "proxmox_virtual_environment_storage_zfspool" "local-zfs" {
  id    = "local-zfs"
  nodes = []

  zfs_pool       = "rpool/data"
  content        = ["images", "rootdir"]
  thin_provision = true
}

resource "proxmox_virtual_environment_storage_nfs" "ds920plus-shared" {
  id     = "ds920plus-shared"
  server = "ds920plus.home.eudald.gr"
  export = "/volume2/pve-shared"

  content = ["vztmpl", "iso", "snippets"]

  snapshot_as_volume_chain = true
}

resource "proxmox_virtual_environment_storage_nfs" "ds920plus-data" {
  id     = "ds920plus-data"
  server = "ds920plus.home.eudald.gr"
  export = "/volume2/pve-data"

  content = ["images", "rootdir"]

  snapshot_as_volume_chain = true
}
