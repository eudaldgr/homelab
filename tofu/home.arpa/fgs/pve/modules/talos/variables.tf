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

variable "cilium_version" {
  description = "Cilium version (e.g. 1.19.0)"
  type        = string
}

variable "cilium_values" {
  description = "Cilium Helm values (YAML string)"
  type        = string
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

variable "dns" {
  description = "DNS configuration for Proxmox nodes"
  type = object({
    domain  = optional(string)
    servers = optional(list(string), ["1.1.1.1", "1.0.0.1"])
  })
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
