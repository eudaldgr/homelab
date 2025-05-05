// variables.pkr.hcl

variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = list(object({
    name        = string
    host        = string
    port        = number
    tls         = bool
    username    = string
    password    = string
    token       = string
    storage     = string
    iso_storage = string
  }))
}

variable "packages_to_install" {
  type    = list(string)
  description = "List of packages to install on the MicroOS template"
  default = []
}

variable "ssh_public_key_file" {
  type        = string
  description = "List of SSH public keys to add to the root user via cloud-init"
  default     = "./ssh/packer.pub"
}

variable "ssh_private_key_file" {
  type        = string
  description = "Path to the SSH private key file"
  default     = "./ssh/packer"
}

variable "user" {
  type        = string
  description = "User for cloud-init"
  default     = "packer"
}

variable "alpine_version" {
  type    = string
  default = "3.21.3"
}

locals {
  alpine_iso_file     = "alpine-virt-${var.alpine_version}-x86_64.iso"
  alpine_iso_url      = "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/${local.alpine_iso_file}"
  alpine_iso_checksum = "file:${local.alpine_iso_url}.sha256"
}