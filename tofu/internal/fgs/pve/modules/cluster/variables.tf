variable "nodes" {
  description = "Nodes del cluster"
  type        = map(any)
}

variable "dns" {
  description = "DNS configuration for Proxmox nodes"
  type = object({
    domain  = optional(string)
    servers = optional(list(string))
  })
}

variable "time_zone" {
  description = "Zona horaria per als nodes del cluster"
  type        = string
  default     = "Europe/Madrid"
}
