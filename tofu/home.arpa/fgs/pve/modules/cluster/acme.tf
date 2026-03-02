resource "proxmox_virtual_environment_acme_account" "main" {
  name      = "main"
  contact   = var.acme_email
  directory = "https://acme-v02.api.letsencrypt.org/directory"
  tos       = "https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf"
}

resource "proxmox_virtual_environment_acme_dns_plugin" "cloudflare" {
  plugin = "cloudflare"
  api    = "cf"
  data = {
    CF_Token = var.cloudflare_api_token
  }
}

resource "proxmox_virtual_environment_acme_certificate" "homelab" {
  for_each  = var.nodes
  node_name = each.key
  account   = proxmox_virtual_environment_acme_account.main.name
  force     = false

  domains = [
    {
      domain = "${each.key}.${var.dns.domain}"
      plugin = proxmox_virtual_environment_acme_dns_plugin.cloudflare.plugin
    }
  ]

  depends_on = [
    proxmox_virtual_environment_acme_account.main,
    proxmox_virtual_environment_acme_dns_plugin.cloudflare
  ]
}
