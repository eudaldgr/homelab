resource "null_resource" "cert_manager_kustomize" {
  depends_on = [null_resource.wait_for_sealed_secrets]

  provisioner "local-exec" {
    command     = <<-EOT
      kustomize build --enable-helm . | kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f - \
        --server-side \
        --force-conflicts
    EOT
    working_dir = "${local.k8s.base_dir}/infrastructure/controllers/cert-manager"
  }
}

resource "null_resource" "wait_for_cert_manager" {
  depends_on = [null_resource.cert_manager_kustomize]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait \
        --kubeconfig="${var.kubeconfig_path}" \
        --for=condition=available \
        --timeout=300s \
        deployment/cert-manager \
        deployment/cert-manager-webhook \
        -n cert-manager
    EOT
  }
}
