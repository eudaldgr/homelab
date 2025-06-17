// variables.pkr.hcl

variable "umbrelos_version" {
  type    = string
  default = "1.4.0"
}

locals {
  umbrelos_base_url          = "https://download.umbrel.com/release/${var.umbrelos_version}"
  umbrelos_img_name          = "umbrelos-amd64.img"
  umbrelos_img_url           = "${local.umbrelos_base_url}/${local.umbrelos_img_name}.xz"
  umbrelos_img_checksum_name = "SHA256SUMS"
  umbrelos_img_checksum_url  = "${local.umbrelos_base_url}/${local.umbrelos_img_checksum_name}"
}