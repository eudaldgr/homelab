variable "proxmox" {
  description = "Proxmox VE API configuration"
  type = object({
    cluster_name = optional(string, "homelab")
    endpoint     = string
    insecure     = optional(bool, false)
  })
}
