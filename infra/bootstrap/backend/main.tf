terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket per tofu state
resource "aws_s3_bucket" "tofu_state" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "TofuState"
    Environment = "homelab"
    ManagedBy   = "opentofu"
  }
}

# Habilitar versionat del bucket
resource "aws_s3_bucket_versioning" "tofu_state" {
  bucket = aws_s3_bucket.tofu_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuració de xifrat
resource "aws_s3_bucket_server_side_encryption_configuration" "tofu_state" {
  bucket = aws_s3_bucket.tofu_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquejar accés públic
resource "aws_s3_bucket_public_access_block" "tofu_state" {
  bucket = aws_s3_bucket.tofu_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuració de lifecycle per gestionar versions antigues
resource "aws_s3_bucket_lifecycle_configuration" "tofu_state" {
  bucket = aws_s3_bucket.tofu_state.id

  rule {
    id     = "tofu_state_lifecycle"
    status = "Enabled"

    # Filter per aplicar la regla a tots els fitxers
    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = var.state_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}