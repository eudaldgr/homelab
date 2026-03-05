output "kubeconfig" {
  description = "Kubernetes kubeconfig for the Talos cluster"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (VIP)"
  value       = "https://${var.vip}:6443"
}

resource "local_file" "kubeconfig" {
  filename             = "${abspath("${path.root}/../output")}/kubeconfig"
  content              = talos_cluster_kubeconfig.this.kubeconfig_raw
  directory_permission = "0700"
  file_permission      = "0600"
}

resource "local_file" "talosconfig" {
  filename             = "${abspath("${path.root}/../output")}/talosconfig"
  content              = data.talos_client_configuration.this.talos_config
  directory_permission = "0700"
  file_permission      = "0600"
}
