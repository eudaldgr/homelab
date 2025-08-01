variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = list(object({
    name        = string
    host        = string
    port        = optional(number, 8006)
    tls         = optional(bool, false)
    username    = optional(string, "root@pam")
    token       = optional(string, "")
    password    = optional(string, "")
    storage     = optional(string, "local-zfs")
    iso_storage = optional(string, "synology")
  }))
}

variable "authorized_ssh_key" {
  description = "SSH public key for authorized access"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtFEdSmdo2wOh1CLWQ7deWuCpvuGceoP9pD6lDRfPVc root@eudald.gr"
}