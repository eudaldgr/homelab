module "cluster" {
  source               = "../modules/cluster"
  nodes                = var.nodes
  dns                  = var.dns
  time_zone            = var.time_zone
  acme_email           = var.acme_email
  cloudflare_api_token = var.cloudflare_api_token
  tofu_user_password   = var.tofu_user_password
}
