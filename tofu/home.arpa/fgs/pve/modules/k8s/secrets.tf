resource "kubernetes_namespace_v1" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "null_resource" "restore_sealed_secrets_master_key" {
  depends_on = [kubernetes_namespace_v1.sealed_secrets]
  count      = var.restore_sealed_secrets_master_key ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f "${local.sealed_secrets_master_key_file}"
    EOT
  }
}
