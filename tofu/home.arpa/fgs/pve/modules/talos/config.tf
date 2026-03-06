resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  for_each = var.controlplanes

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.vip}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/machine-config/controlplane.yaml.tftpl", {
      cert_sans      = local.cert_sans
      vip            = var.vip
      cluster_name   = var.cluster_name
      node_name      = each.value.node
      cluster_domain = var.dns.domain
      hostname       = each.key
    }),
    local.cilium_patch,
    local.coredns_patch,
  ]
}

data "talos_machine_configuration" "worker" {
  for_each = var.workers

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.vip}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  config_patches = [
    templatefile("${path.module}/machine-config/worker.yaml.tftpl", {
      cert_sans      = local.cert_sans
      igpu           = each.value.igpu
      cluster_name   = var.cluster_name
      node_name      = each.value.node
      cluster_domain = var.dns.domain
      hostname       = each.key
    }),
    local.cilium_patch,
    local.coredns_patch,
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.controlplanes

  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration

  depends_on = [proxmox_virtual_environment_vm.talos]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = var.workers

  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration

  depends_on = [proxmox_virtual_environment_vm.talos]
}
