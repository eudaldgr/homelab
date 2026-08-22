variable "proxmox" {
  description = "Proxmox VE API configuration"
  type = object({
    endpoint  = string
    api_token = optional(string)
    insecure  = optional(bool, false)
  })
}

variable "nodes" {
  description = "Map of Proxmox nodes with storage configuration"
  type = map(object({
    local_storage = optional(string, "local-zfs")
    iso_storage   = optional(string, "ds920plus-shared")
  }))
}

variable "talos" {
  description = "Talos image configuration"
  type = object({
    talos_version = string
  })
}

variable "talos_controlplanes" {
  description = "Talos virtual machines"
  type = map(object({
    node   = string
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    mac    = string
  }))
}
