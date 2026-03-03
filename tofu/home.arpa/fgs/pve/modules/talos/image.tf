## Standard schematic (control planes) -------------------------------------------
resource "talos_image_factory_schematic" "std" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/iscsi-tools",
          "siderolabs/qemu-guest-agent",
        ]
      }
    }
  })
}

data "talos_image_factory_urls" "std" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.std.id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_virtual_environment_download_file" "talos_std" {
  node_name    = sort(keys(var.nodes))[0]
  content_type = "iso"
  datastore_id = var.nodes[sort(keys(var.nodes))[0]].iso_storage

  file_name               = "talos-${var.talos_version}-std-nocloud-amd64.img"
  url                     = data.talos_image_factory_urls.std.urls.disk_image
  decompression_algorithm = "zst"
  overwrite               = false
}

## GPU schematic (workers with i915) ---------------------------------------------
resource "talos_image_factory_schematic" "gpu" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/i915",
          "siderolabs/intel-ucode",
          "siderolabs/iscsi-tools",
          "siderolabs/qemu-guest-agent",
        ]
      }
    }
  })
}

data "talos_image_factory_urls" "gpu" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.gpu.id
  platform      = "nocloud"
  architecture  = "amd64"
}

resource "proxmox_virtual_environment_download_file" "talos_gpu" {
  node_name    = sort(keys(var.nodes))[0]
  content_type = "iso"
  datastore_id = var.nodes[sort(keys(var.nodes))[0]].iso_storage

  file_name               = "talos-${var.talos_version}-gpu-nocloud-amd64.img"
  url                     = data.talos_image_factory_urls.gpu.urls.disk_image
  decompression_algorithm = "zst"
  overwrite               = false
}
