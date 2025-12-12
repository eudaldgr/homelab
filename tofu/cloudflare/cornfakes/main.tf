# Llegeix l'state del projecte infra/hetzner/homelab
data "terraform_remote_state" "homelab" {
  backend = "s3"
  config = {
    bucket = "e17n-homelab-tofu-state"
    key    = "infra/hetzner/homelab/terraform.tfstate"
    region = "eu-west-3"
  }
}

# Wildcard DNS a Cloudflare
resource "cloudflare_dns_record" "wildcard" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.domain}"
  type    = "A"
  ttl     = 1
  proxied = false

  content = data.terraform_remote_state.homelab.outputs.server_ip
}
