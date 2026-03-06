// variables.pkr.hcl

# hcloud variables
variable "hcloud_token" {
  type      = string
  default   = env("HCLOUD_TOKEN")
  sensitive = true
}

# microOS variables
variable "packages_to_install" {
  type        = list(string)
  description = "List of packages to install on the MicroOS template"
  default     = []
}

locals {
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
