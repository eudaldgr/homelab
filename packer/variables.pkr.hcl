// variables.pkr.hcl

# proxmox variables
variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = list(object({
    name          = string
    host          = string
    port          = number
    tls           = bool
    username      = string
    password      = string
    token         = string
    local_storage = string
    iso_storage   = string
    data_storage  = string
  }))
}

# hcloud variables
variable "hcloud_token" {
  type      = string
  default   = env("HCLOUD_TOKEN")
  sensitive = true
}

# ssh variables
variable "ssh_public_key_file" {
  type        = string
  description = "List of SSH public keys to add to the root user via cloud-init"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the SSH private key file"
  default     = "~/.ssh/id_ed25519"
}

# microOS variables
variable "packages_to_install" {
  type        = list(string)
  description = "List of packages to install on the MicroOS template"
  default     = []
}

# alpine variables
variable "alpine_version" {
  type    = string
  default = "3.23.3"
}

locals {
  # alpine local variables
  alpine_iso_file      = "alpine-virt-${var.alpine_version}-x86_64.iso"
  alpine_iso_url      = "https://dl-cdn.alpinelinux.org/alpine/v${join(".", slice(split(".", var.alpine_version), 0, 2))}/releases/x86_64/${local.alpine_iso_file}"
  alpine_iso_checksum = "file:${local.alpine_iso_url}.sha256"
  
  # microOS local variables
  microos_x86_img_name         = "openSUSE-MicroOS.x86_64-ContainerHost-OpenStack-Cloud.qcow2"
  microos_x86_img_url          = "https://download.opensuse.org/tumbleweed/appliances/${local.microos_x86_img_name}"
  microos_x86_img_checksum_url = "${local.microos_x86_img_url}.sha256"

  microos_arm_img_name         = "openSUSE-MicroOS.aarch64-ContainerHost-OpenStack-Cloud.qcow2"
  microos_arm_img_url          = "https://download.opensuse.org/ports/aarch64/tumbleweed/appliances/${local.microos_arm_img_name}"
  microos_arm_img_checksum_url = "${local.microos_arm_img_url}.sha256"

  # utils
  download_image = "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only"
}
