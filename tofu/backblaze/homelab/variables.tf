variable "buckets" {
  description = "Buckets Backblaze B2 i keys dedicades per servei."
  type = map(object({
    bucket_name  = string
    bucket_type  = string
    key_name     = string
    capabilities = list(string)
  }))

  default = {
    velero = {
      bucket_name  = "homelab-velero-b2"
      bucket_type  = "allPrivate"
      key_name     = "velero-b2-key"
      capabilities = ["listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
    }
  }

  validation {
    condition     = length(var.buckets) > 0
    error_message = "Has de definir com a minim un bucket."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.buckets : contains(["allPrivate", "allPublic"], cfg.bucket_type)
    ])
    error_message = "bucket_type ha de ser allPrivate o allPublic."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.buckets : length(cfg.capabilities) > 0
    ])
    error_message = "Cada bucket ha de tenir almenys una capability."
  }

  validation {
    condition = length(distinct([
      for _, cfg in var.buckets : cfg.bucket_name
    ])) == length(var.buckets)
    error_message = "Els bucket_name han de ser unics."
  }

  validation {
    condition = length(distinct([
      for _, cfg in var.buckets : cfg.key_name
    ])) == length(var.buckets)
    error_message = "Els key_name han de ser unics."
  }
}

variable "b2_endpoint" {
  type        = string
  description = "Endpoint S3 compatible de Backblaze B2."
  default     = "https://s3.us-west-002.backblazeb2.com"
}

variable "b2_application_key_id" {
  type        = string
  description = "Application Key ID de Backblaze B2 per autenticar el provider."
  sensitive   = true
  default     = null
  nullable    = true
}

variable "b2_application_key" {
  type        = string
  description = "Application Key secret de Backblaze B2 per autenticar el provider."
  sensitive   = true
  default     = null
  nullable    = true
}
