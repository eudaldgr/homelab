variable "proxmox_nodes" {
  description = "List of Proxmox nodes"
  type = list(object({
    name          = string
    host          = string
    port          = optional(number, 8006)
    tls           = optional(bool, false)
    username      = optional(string, "root@pam")
    token         = optional(string, "")
    password      = optional(string, "")
    local_storage = optional(string, "local-zfs")
    iso_storage   = optional(string, "ds920plus-shared")
    data_storage  = optional(string, "ds920plus-data")
  }))
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key used to connect to Proxmox node"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
