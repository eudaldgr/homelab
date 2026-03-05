variable "proxmox" {
  description = "Proxmox VE API configuration"
  type = object({
    cluster_name = optional(string, "homelab")
    endpoint     = string
    insecure     = optional(bool, false)
  })
}

variable "restore_sealed_secrets_master_key" {
  description = "Restore Sealed Secrets master key from ./secrets/sealed-secrets-master-keys.yaml"
  type        = bool
  default     = false
}
