resource "null_resource" "sealed_secrets_kustomize" {
  depends_on = [
    kubernetes_namespace_v1.sealed_secrets,
    null_resource.restore_sealed_secrets_master_key
  ]

  provisioner "local-exec" {
    command     = <<-EOT
      kustomize build --enable-helm . | kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f - \
        --server-side \
        --force-conflicts
    EOT
    working_dir = "${local.k8s.base_dir}/infrastructure/controllers/sealed-secrets"
  }
}

resource "null_resource" "wait_for_sealed_secrets" {
  depends_on = [null_resource.sealed_secrets_kustomize]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait \
        --kubeconfig="${var.kubeconfig_path}" \
        --for=condition=available \
        --timeout=300s \
        deployment/sealed-secrets \
        -n sealed-secrets
    EOT
  }
}
