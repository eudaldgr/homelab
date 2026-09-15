locals {
  labels = {
    app        = "towonel"
    managed_by = "opentofu"
  }
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  # HTTP
  # HTTPS
  # Synology Drive Client/Server
  public_tcp_ports = [
    80,
    443,
    6690
  ]
  # HTTP/3
  # WireGuard
  public_udp_ports = [
    443,
    51820
  ]
}

resource "hcloud_ssh_key" "cadi" {
  name       = "${var.hostname}-bootstrap"
  public_key = local.ssh_public_key
  labels     = local.labels
}

resource "hcloud_firewall" "cadi" {
  name   = "${var.hostname}-firewall"
  labels = local.labels

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"] # var.ssh_source_ips
  }

  dynamic "rule" {
    for_each = local.public_tcp_ports
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = tostring(rule.value)
      source_ips = ["0.0.0.0/0"]
    }
  }

  dynamic "rule" {
    for_each = local.public_udp_ports
    content {
      direction  = "in"
      protocol   = "udp"
      port       = tostring(rule.value)
      source_ips = ["0.0.0.0/0"]
    }
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0"]
  }
}

resource "hcloud_server" "cadi" {
  name         = var.hostname
  image        = "ubuntu-26.04"
  server_type  = var.server_type
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.cadi.id]
  firewall_ids = [hcloud_firewall.cadi.id]
  labels       = local.labels

  user_data = "#cloud-config\n${yamlencode({
    disable_root = true
    ssh_pwauth   = false
    users = [
      {
        name                = "ubuntu"
        groups              = "sudo"
        lock_passwd         = true
        shell               = "/bin/bash"
        sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
        ssh_authorized_keys = [local.ssh_public_key]
      }
    ]
  })}"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  lifecycle {
    prevent_destroy = true
  }
}
