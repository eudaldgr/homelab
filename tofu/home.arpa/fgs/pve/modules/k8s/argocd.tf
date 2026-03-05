resource "null_resource" "argocd_kustomize" {
  provisioner "local-exec" {
    command     = <<-EOT
      kustomize build --enable-helm . | kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f - \
        --server-side \
        --force-conflicts
    EOT
    working_dir = "${local.k8s.base_dir}/infrastructure/argocd/overlays/prod"
  }
}

resource "null_resource" "wait_for_argocd" {
  depends_on = [null_resource.argocd_kustomize]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl wait \
        --kubeconfig="${var.kubeconfig_path}" \
        --for=condition=available \
        --timeout=300s \
        deployment/argocd-server \
        deployment/argocd-repo-server \
        deployment/argocd-applicationset-controller \
        -n argocd
    EOT
  }
}

# System
resource "null_resource" "system_project" {
  depends_on = [null_resource.wait_for_argocd]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/system/project.yaml
    EOT
  }
}

resource "null_resource" "system_appset" {
  depends_on = [null_resource.system_project]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/system/applicationset.yaml
    EOT
  }
}

# Infrastructure
resource "null_resource" "infrastructure_project" {
  depends_on = [null_resource.wait_for_argocd]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/infrastructure/project.yaml
    EOT
  }
}

resource "null_resource" "infrastructure_appset" {
  depends_on = [
    null_resource.infrastructure_project,
    null_resource.system_appset
  ]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/infrastructure/applicationset.yaml
    EOT
  }
}

# Applications
resource "null_resource" "applications_project" {
  depends_on = [null_resource.wait_for_argocd]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/applications/project.yaml
    EOT
  }
}

resource "null_resource" "applications_appset" {
  depends_on = [
    null_resource.applications_project,
    null_resource.infrastructure_appset
  ]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply \
        --kubeconfig="${var.kubeconfig_path}" \
        -f ${local.k8s.base_dir}/clusters/prod/${var.proxmox.cluster_name}/applications/applicationset.yaml
    EOT
  }
}
