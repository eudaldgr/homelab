variable "proxmox" {
  description = "Proxmox VE API configuration"
  type = object({
    cluster_name = optional(string, "homelab")
    endpoint     = string
    username     = optional(string, "root@pam")
    password     = optional(string)
    api_token    = optional(string)
    insecure     = optional(bool, false)
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
  description = "Talos cluster configuration"
  type = object({
    cluster_name       = optional(string, "homelab")
    vip                = string
    gateway            = string
    subnet             = string
    talos_version      = string
    kubernetes_version = string
  })
}

variable "talos_controlplanes" {
  description = "Talos control plane nodes"
  type = map(object({
    node               = string
    vmid               = number
    cores              = number
    memory             = number
    disk               = number
    ip                 = string
    mac                = string
    storage_ip         = optional(string)
    storage_mac        = optional(string)
    igpu               = optional(bool, false)
    schedule_workloads = optional(bool, false)
  }))
}

variable "talos_workers" {
  description = "Talos worker nodes"
  type = map(object({
    node        = string
    vmid        = number
    cores       = number
    memory      = number
    disk        = number
    ip          = string
    mac         = string
    storage_ip  = optional(string)
    storage_mac = optional(string)
    igpu        = optional(bool, false)
  }))
  default  = null
  nullable = true
}
