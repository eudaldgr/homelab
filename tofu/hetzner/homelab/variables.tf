variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "pangolin01"
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Hetzner"
  type        = string
  default     = "laptop-key"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_user" {
  description = "SSH user to connect for token retrieval"
  type        = string
  default     = "root"
}

variable "timezone" {
  description = "Timezone for the server"
  type        = string
  default     = "Europe/Madrid"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}
