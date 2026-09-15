locals {
  labels = {
    app        = "pangolin"
    managed_by = "opentofu"
  }
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  # 80 - HTTP
  # 443 - HTTPS
  # 6690 - Synology Drive Client/Server
  # 25565 - Minecraft Java
  public_tcp_ports = [
    80,
    443,
    6690
  ]
  # 443 - HTTP/3
  # 21820 - Gerbil/Pangolin WireGuard for clients
  # 51820 - Gerbil/Pangolin WireGuard
  # 19132 - Minecraft Bedrock
  public_udp_ports = [
    443,
    21820,
    51820
  ]
}

data "hcloud_image" "microos" {
  with_selector = "microos-snapshot=yes,podman-host=yes"
  most_recent   = true
}

resource "hcloud_ssh_key" "homelab" {
  name       = "${var.hostname}-bootstrap"
  public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  labels     = local.labels
}

resource "hcloud_firewall" "homelab" {
  name   = "${var.hostname}-firewall"
  labels = local.labels

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"]
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

resource "hcloud_server" "homelab" {
  name         = var.hostname
  image        = data.hcloud_image.microos.id
  server_type  = var.server_type
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.homelab.id]
  firewall_ids = [hcloud_firewall.homelab.id]
  labels       = local.labels

  user_data = "#cloud-config\n${yamlencode({
    disable_root = true
    ssh_pwauth   = false
    users = [
      {
        name                = "eudaldgr"
        groups              = ["sudo", "systemd-journal", "users"]
        lock_passwd         = true
        shell               = "/bin/bash"
        sudo                = ["ALL=(ALL) NOPASSWD:ALL"]
        ssh_authorized_keys = [local.ssh_public_key]
      }
    ]
    power_state = {
      mode      = "reboot"
      timeout   = 30
      condition = true
    }
  })}"

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
}
