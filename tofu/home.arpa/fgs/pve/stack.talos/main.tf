module "talos" {
  source = "../modules/talos"

  cluster_name       = var.talos.cluster_name
  talos_version      = var.talos.talos_version
  kubernetes_version = var.talos.kubernetes_version
  cilium_version     = var.talos.cilium_version
  cilium_values      = file("${path.module}/../../../../../k8s/system/cilium/overlays/prod/values.yaml")
  vip                = var.talos.vip
  gateway            = var.talos.gateway
  subnet             = var.talos.subnet
  dns                = var.dns
  controlplanes      = var.talos_controlplanes
  workers            = var.talos_workers
  nodes              = var.nodes
}
