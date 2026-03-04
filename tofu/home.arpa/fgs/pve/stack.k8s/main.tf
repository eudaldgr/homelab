module "k8s" {
  source = "../modules/k8s"

  proxmox = var.proxmox
}
