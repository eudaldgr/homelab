output "tofu_proxmox_api_token" {
  description = "API token for Proxmox provider"
  value       = module.cluster.tofu_proxmox_api_token
  sensitive   = true
}
