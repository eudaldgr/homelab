/*
 * Creates a MicroOS snapshot for hetzner.
 */

# x86 MicroOS source
source "hcloud" "microos-x86-snapshot" {
  image       = "ubuntu-24.04"
  rescue      = "linux64"
  location    = "fsn1"
  server_type = "cx22" # >= 40GiB
  snapshot_labels = {
    microos-snapshot = "yes"
    creator          = "e17n"
  }
  snapshot_name = "OpenSUSE MicroOS x86 by e17n"
  ssh_username  = "root"
  token         = var.hcloud_token
}

# arm MicroOS source
source "hcloud" "microos-arm-snapshot" {
  image       = "ubuntu-24.04"
  rescue      = "linux64"
  location    = "fsn1"
  server_type = "cax11" # >= 40GiB
  snapshot_labels = {
    microos-snapshot = "yes"
    creator          = "e17n"
  }
  snapshot_name = "OpenSUSE MicroOS ARM by e17n"
  ssh_username  = "root"
  token         = var.hcloud_token
}

# x86 MicroOS image
build {
  sources = ["source.hcloud.microos-x86-snapshot"]

  # Download the MicroOS image
  provisioner "shell" {
    inline = [
      "${local.download_image} ${local.microos_x86_img_url}          -O ${local.microos_x86_img_name}        >/dev/null 2>&1",
      "${local.download_image} ${local.microos_x86_img_checksum_url} -O ${local.microos_x86_img_name}.sha256 >/dev/null 2>&1"
    ]
  }

  # Convert the MicroOS image to raw format and write it to disk
  provisioner "shell" {
    inline            = [local.write_image]
    expect_disconnect = true
  }

  # Install packages
  provisioner "shell" {
    pause_before      = "5s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }

  # Do house-keeping
  provisioner "shell" {
    pause_before = "5s"
    inline       = [local.clean_up]
  }
}

# arm MicroOS image
build {
  sources = ["source.hcloud.microos-arm-snapshot"]

  # Download the MicroOS image
  provisioner "shell" {
    inline = [
      "${local.download_image} ${local.microos_arm_img_url}          -O ${local.microos_arm_img_name}        >/dev/null 2>&1",
      "${local.download_image} ${local.microos_arm_img_checksum_url} -O ${local.microos_arm_img_name}.sha256 >/dev/null 2>&1"
    ]
  }

  # Convert the MicroOS image to raw format and write it to disk
  provisioner "shell" {
    inline            = [local.write_image]
    expect_disconnect = true
  }

  # Install packages
  provisioner "shell" {
    pause_before      = "5s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }

  # Do house-keeping
  provisioner "shell" {
    pause_before = "5s"
    inline       = [local.clean_up]
  }
}