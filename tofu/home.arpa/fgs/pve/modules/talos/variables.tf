variable "proxmox_cluster_name" {
  description = "Name of the Proxmox cluster (used for tagging and naming)"
  type        = string
}

variable "cluster_name" {
  description = "Talos cluster name"
  type        = string
}

variable "talos_version" {
  description = "Talos version (e.g. v1.12.4)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. v1.35.0)"
  type        = string
}

variable "check_cluster_health" {
  description = "Run the Talos cluster health data source during planning/apply. Keep disabled for routine plans to avoid long health checks."
  type        = bool
  default     = false
}

variable "vip" {
  description = "Virtual IP for the Kubernetes API server"
  type        = string
}

variable "gateway" {
  description = "Default gateway for Talos nodes"
  type        = string
}

variable "subnet" {
  description = "Subnet CIDR for Talos node IPs (e.g. 192.168.20.0/24)"
  type        = string
}

variable "controlplanes" {
  description = "Map of control plane nodes"
  type = map(object({
    node   = string
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    ip     = string
    mac    = string
    igpu   = optional(bool, false)
  }))
}

variable "workers" {
  description = "Map of worker nodes"
  type = map(object({
    node   = string
    vmid   = number
    cores  = number
    memory = number
    disk   = number
    ip     = string
    mac    = string
    igpu   = optional(bool, false)
  }))
}

variable "nodes" {
  description = "Proxmox nodes configuration (from root module)"
  type = map(object({
    local_storage = string
    iso_storage   = string
  }))
}
