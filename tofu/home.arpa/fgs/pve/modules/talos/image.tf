resource "talos_image_factory_schematic" "gpu" {
  # One hardware definition for VM boot images and Talos/Tuppr installers.
  schematic = file("${path.module}/../../../../../../talos/schematic.yaml.j2")
}

data "talos_image_factory_urls" "gpu" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.gpu.id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_download_file" "talos_gpu" {
  for_each = var.nodes

  node_name    = each.key
  content_type = "iso"
  datastore_id = each.value.iso_storage

  file_name               = "talos-${var.talos_version}-gpu-nocloud-amd64.img"
  url                     = data.talos_image_factory_urls.gpu.urls.disk_image
  decompression_algorithm = "zst"
  overwrite               = false
}
