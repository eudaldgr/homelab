locals {
  # Merge all nodes into a single map with role annotation
  all_nodes = merge(
    { for k, v in var.controlplanes : k => merge(v, { role = "controlplane" }) },
    { for k, v in var.workers : k => merge(v, { role = "worker" }) },
  )

  # First control plane for bootstrap
  first_cp_name = sort(keys(var.controlplanes))[0]
  first_cp_ip   = var.controlplanes[local.first_cp_name].ip

  # Node IP lists for health check
  cp_ips     = [for k, v in var.controlplanes : v.ip]
  worker_ips = [for k, v in var.workers : v.ip]

  # Certificate SANs: VIP + all node IPs
  cert_sans = concat([var.vip], local.cp_ips, local.worker_ips)

  # Kubernetes base directory for file references
  k8s = {
    base_dir = "${path.module}/../../../../../../k8s"
  }
}
