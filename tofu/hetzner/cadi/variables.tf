variable "hostname" {
  description = "Hetzner server name"
  type        = string
  default     = "cadi"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Hetzner location"
  type        = string
  default     = "nbg1"
}

variable "ssh_public_key_path" {
  description = "Public key installed for the ubuntu user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_source_ips" {
  description = "IPv4 CIDRs allowed to reach SSH"
  type        = set(string)

  # validation {
  #   condition     = length(var.ssh_source_ips) > 0
  #   error_message = "Set at least one trusted IPv4 CIDR for SSH."
  # }
  nullable = true
  default  = null
}
