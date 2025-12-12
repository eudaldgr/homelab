variable "cloudflare_api_token" {
  description = "Token d'API de Cloudflare amb permisos per gestionar DNS"
  type        = string
}

variable "domain" {
  description = "Domini principal gestionat a Cloudflare"
  type        = string
  default     = "cornfakes.xyz"
}

variable "cloudflare_zone_id" {
  description = "Zone ID de Cloudflare"
  type        = string
}
