output "talos_kubeconfig" {
  description = "Kubernetes kubeconfig for the Talos cluster"
  value       = module.talos.kubeconfig
  sensitive   = true
}

output "talos_talosconfig" {
  description = "Talos client configuration"
  value       = module.talos.talosconfig
  sensitive   = true
}

output "talos_cluster_endpoint" {
  description = "Kubernetes API endpoint (VIP)"
  value       = module.talos.cluster_endpoint
}
