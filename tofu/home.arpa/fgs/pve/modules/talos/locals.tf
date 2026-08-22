locals {
  all_nodes = { for k, v in var.controlplanes : k => merge(v, { role = "controlplane" }) }
}
