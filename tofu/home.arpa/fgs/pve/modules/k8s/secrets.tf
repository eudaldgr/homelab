resource "null_resource" "restore_sealed_secrets_master_key" {
  count = var.restore_sealed_secrets_master_key ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f "${local.sealed_secrets_master_key_file}"
    EOT
  }
}
