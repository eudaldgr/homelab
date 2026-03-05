module "k8s" {
  source = "../modules/k8s"

  proxmox                           = var.proxmox
  restore_sealed_secrets_master_key = var.restore_sealed_secrets_master_key
  kubeconfig_path                   = abspath("${path.root}/../output/kubeconfig")
}
