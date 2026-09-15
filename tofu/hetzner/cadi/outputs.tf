output "server_ip" {
  description = "Public IPv4 address of the Cadi VPS"
  value       = hcloud_server.cadi.ipv4_address
}

output "hub_url" {
  description = "Public Towonel hub URL after DNS is configured"
  value       = "https://towonel.eudald.gr"
}
