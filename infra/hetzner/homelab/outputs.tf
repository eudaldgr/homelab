output "server_ip" {
  description = "Public IP address of the homelab server"
  value       = hcloud_server.homelab.ipv4_address
}

output "server_name" {
  description = "Name of the homelab server"
  value       = hcloud_server.homelab.name
}