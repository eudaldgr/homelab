variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Name of the Hetzner server"
  type        = string
  default     = "pangolin-01"
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

variable "ssh_private_key_path" {
  description = "Path to SSH private key for connecting to the new server"
  type        = string
  default     = "~/.ssh/id_ed25519"
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

variable "base_domain" {
  description = "Base domain for the homelab"
  type        = string
  default     = "cornfakes.xyz"
}

variable "letsencrypt_mail" {
  description = "Email for Let's Encrypt notifications"
  type        = string
  default     = "le@eudald.gr"
}

variable "pangolin_domain" {
  description = "Pangolin domain for tunnel configuration"
  type        = string
  default     = "pangolin.cornfakes.xyz"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"
}

variable "smtp_host" {
  description = "SMTP server host"
  type        = string
  default     = "smtp.cornfakes.xyz"
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = number
  default     = 587
}

variable "smtp_user" {
  description = "SMTP server username"
  type        = string
  default     = "random-user"
}

variable "smtp_pass" {
  description = "SMTP server password"
  type        = string
  default     = "random-pass"
  sensitive   = true
}

variable "smtp_secure" {
  description = "Use secure connection for SMTP"
  type        = bool
  default     = false
}

variable "no_reply_email" {
  description = "No-reply email address"
  type        = string
  default     = "noreply@cornfakes.xyz"
}
