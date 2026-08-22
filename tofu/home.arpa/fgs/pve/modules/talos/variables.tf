variable "talos_version" {
  description = "Talos version (e.g. v1.12.4)"
  type        = string
}

variable "controlplanes" {
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

variable "nodes" {
  description = "Proxmox nodes configuration (from root module)"
  type = map(object({
    local_storage = string
    iso_storage   = string
  }))
}
