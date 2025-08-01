variable "bucket_name" {
  type        = string
  description = "Nom del bucket S3 per terraform.tfstate"
  default     = "e17n-homelab-tofu-state"
}

variable "aws_region" {
  type        = string
  description = "Regió AWS on crear els recursos"
  default     = "eu-west-3"
}

variable "state_retention_days" {
  type        = number
  description = "Dies per mantenir versions antigues de l'estat"
  default     = 30
}