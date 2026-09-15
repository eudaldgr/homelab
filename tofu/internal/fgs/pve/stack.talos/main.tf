module "talos" {
  source = "../modules/talos"

  talos_version = var.talos.talos_version
  controlplanes = var.talos_controlplanes
  nodes         = var.nodes
}
