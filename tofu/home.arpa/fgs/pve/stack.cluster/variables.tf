variable "proxmox" {
  description = "Proxmox VE API configuration"
  type = object({
    endpoint  = string
    username  = optional(string, "root@pam")
    password  = optional(string)
    api_token = optional(string)
    insecure  = optional(bool, false)
  })
}

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
}

variable "acme_email" {
  description = "Email for ACME/Let's Encrypt account"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for DNS-01 challenge"
  type        = string
  sensitive   = true
}
