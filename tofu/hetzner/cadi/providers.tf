terraform {
  required_version = "~> 1.16.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }

  backend "s3" {
    profile                     = "garage"
    bucket                      = "tofu"
    key                         = "hetzner/cadi.tfstate"
    region                      = "garage"
    use_path_style              = true
    use_lockfile                = true
    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "hcloud" {}
