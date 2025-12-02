terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  alias               = "pve"
  for_each            = { for node in var.proxmox_nodes : node.name => node }
  pm_api_url          = "https://${each.value.host}:${each.value.port}/api2/json"
  pm_api_token_id     = each.value.username
  pm_api_token_secret = each.value.token
  pm_tls_insecure     = !each.value.tls

  pm_minimum_permission_check = false
}

provider "proxmox" {
  alias               = "pve01"
  pm_api_url          = "https://${var.proxmox_nodes[0].host}:${var.proxmox_nodes[0].port}/api2/json"
  pm_api_token_id     = var.proxmox_nodes[0].username
  pm_api_token_secret = var.proxmox_nodes[0].token
  pm_tls_insecure     = !var.proxmox_nodes[0].tls

  pm_minimum_permission_check = false
}

provider "proxmox" {
  alias               = "pve02"
  pm_api_url          = "https://${var.proxmox_nodes[1].host}:${var.proxmox_nodes[1].port}/api2/json"
  pm_api_token_id     = var.proxmox_nodes[1].username
  pm_api_token_secret = var.proxmox_nodes[1].token
  pm_tls_insecure     = !var.proxmox_nodes[1].tls

  pm_minimum_permission_check = false
}
