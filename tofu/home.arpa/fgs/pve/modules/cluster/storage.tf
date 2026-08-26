resource "proxmox_storage_directory" "local" {
  id    = "local"
  path  = "/var/lib/vz"
  nodes = []

  content = ["backup", "import", "iso", "vztmpl"]
  shared  = false
  disable = false
}

resource "proxmox_storage_zfspool" "local-zfs" {
  id    = "local-zfs"
  nodes = []

  zfs_pool       = "rpool/data"
  content        = ["images", "rootdir"]
  thin_provision = true
}
