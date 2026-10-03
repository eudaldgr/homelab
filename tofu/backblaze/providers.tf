terraform {
  required_version = ">= 1.0.0"

  required_providers {
    b2 = {
      source  = "registry.terraform.io/backblaze/b2"
      version = "0.14.0"
    }
  }

  backend "s3" {
    profile                     = "garage"
    bucket                      = "tofu"
    key                         = "backblaze/terraform.tfstate"
    region                      = "garage"
    use_path_style              = true
    use_lockfile                = true
    encrypt                     = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "b2" {}
