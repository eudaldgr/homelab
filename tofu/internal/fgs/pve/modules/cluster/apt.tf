# ------------------------------
# Enterprise repo (deshabilitat)
# ------------------------------
resource "proxmox_apt_standard_repository" "enterprise" {
  for_each = var.nodes
  handle   = "enterprise"
  node     = each.key
}

resource "proxmox_apt_repository" "enterprise" {
  for_each  = var.nodes
  enabled   = false
  file_path = proxmox_apt_standard_repository.enterprise[each.key].file_path
  index     = proxmox_apt_standard_repository.enterprise[each.key].index
  node      = each.key
}

# ------------------------------
# No-subscription repo (habilitat)
# ------------------------------
resource "proxmox_apt_standard_repository" "no_subscription" {
  for_each = var.nodes
  handle   = "no-subscription"
  node     = each.key
}

resource "proxmox_apt_repository" "no_subscription" {
  for_each  = var.nodes
  enabled   = true
  file_path = proxmox_apt_standard_repository.no_subscription[each.key].file_path
  index     = proxmox_apt_standard_repository.no_subscription[each.key].index
  node      = each.key
}

# ------------------------------
# Ceph no-subscription (opcional)
# ------------------------------
resource "proxmox_apt_standard_repository" "ceph_no_subscription" {
  for_each = var.nodes
  handle   = "ceph-squid-no-subscription"
  node     = each.key
}

resource "proxmox_apt_repository" "ceph_no_subscription" {
  for_each  = var.nodes
  enabled   = true
  file_path = proxmox_apt_standard_repository.ceph_no_subscription[each.key].file_path
  index     = proxmox_apt_standard_repository.ceph_no_subscription[each.key].index
  node      = each.key
}

# ------------------------------
# Debian Trixie repos (debian.sources)
# index 0: trixie + trixie-updates main contrib
# index 1: trixie-security main contrib
# ------------------------------
resource "proxmox_apt_repository" "debian_trixie" {
  for_each  = var.nodes
  enabled   = true
  file_path = "/etc/apt/sources.list.d/debian.sources"
  index     = 0
  node      = each.key
}

resource "proxmox_apt_repository" "debian_trixie_security" {
  for_each  = var.nodes
  enabled   = true
  file_path = "/etc/apt/sources.list.d/debian.sources"
  index     = 1
  node      = each.key
}
