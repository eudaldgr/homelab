# Hetzner homelab infrastructure with Pangolin

# Data source to get the MicroOS snapshot
data "hcloud_image" "microos" {
  with_selector = "microos-snapshot=yes"
  most_recent   = true
}

# SSH key for VMs
resource "hcloud_ssh_key" "homelab" {
  name       = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

# Firewall for homelab with Pangolin
resource "hcloud_firewall" "homelab" {
  name = "homelab-firewall"

  # SSH access
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP - només si no fas servir wildcard (Let’s Encrypt HTTP-01)
  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTPS (obligatori per Pangolin)
  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Pangolin/Gerbil site tunnels (Newt -> Gerbil)
  rule {
    direction  = "in"
    port       = "51820"
    protocol   = "udp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Pangolin/Gerbil client tunnels (Client -> Gerbil -> Newt)
  rule {
    direction  = "in"
    port       = "21820"
    protocol   = "udp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Homelab pangolin server
resource "hcloud_server" "homelab" {
  name        = var.hostname
  image       = data.hcloud_image.microos.id
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.homelab.id]
  firewall_ids = [hcloud_firewall.homelab.id]

  labels = {
    type = "homelab"
    role = "pangolin"
  }

  user_data = templatefile("${path.module}/files/cloud-init.yml", {
    hostname            = var.hostname
    timezone            = var.timezone
    base_domain         = var.base_domain
    pangolin_domain     = var.pangolin_domain
    letsencrypt_mail    = var.letsencrypt_mail
    ssh_authorized_keys = file(var.ssh_public_key_path)
    smtp_host           = var.smtp_host
    smtp_port           = var.smtp_port
    smtp_user           = var.smtp_user
    smtp_pass           = var.smtp_pass
    smtp_secure         = var.smtp_secure
    no_reply_email      = var.no_reply_email
  })
}

# Wait for Pangolin token to appear in logs and output it
data "external" "pangolin_token" {
  program = ["bash", "-c", "${path.module}/files/script.sh ${hcloud_server.homelab.ipv4_address}"]
  depends_on = [hcloud_server.homelab]
}
