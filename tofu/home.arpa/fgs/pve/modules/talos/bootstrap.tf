resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.first_cp_ip

  depends_on = [talos_machine_configuration_apply.controlplane]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.first_cp_ip

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker,
  ]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in local.all_nodes : v.ip]
  endpoints            = [for k, v in var.controlplanes : v.ip]
}

data "talos_cluster_health" "this" {
  count = var.check_cluster_health ? 1 : 0

  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = [for k, v in talos_machine_configuration_apply.controlplane : v.node]
  worker_nodes         = [for k, v in talos_machine_configuration_apply.worker : v.node]
  endpoints            = [for k, v in talos_machine_configuration_apply.controlplane : v.node]

  timeouts = {
    read = "5m"
  }

  depends_on = [
    talos_cluster_kubeconfig.this,
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker,
  ]
}
