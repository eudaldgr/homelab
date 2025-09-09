output "server_ip" {
  description = "Public IP address of the homelab server"
  value       = hcloud_server.homelab.ipv4_address
}

output "server_name" {
  description = "Name of the homelab server"
  value       = hcloud_server.homelab.name
}

output "pangolin_domain" {
  description = "Pangolin domain for tunnel configuration"
  value       = var.pangolin_domain
}

output "pangolin_token" {
  description = "Pangolin token for initial setup"
  value       = try(data.external.pangolin_token.result, "")
  sensitive   = true
}