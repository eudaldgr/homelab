module "talos" {
  source = "../modules/talos"

  proxmox_cluster_name = var.proxmox.cluster_name
  cluster_name         = var.talos.cluster_name
  talos_version        = var.talos.talos_version
  kubernetes_version   = var.talos.kubernetes_version
  vip                  = var.talos.vip
  gateway              = var.talos.gateway
  subnet               = var.talos.subnet
  controlplanes        = var.talos_controlplanes
  workers              = var.talos_workers
  nodes                = var.nodes
}
