terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.3.0"
    }
  }
}

provider "kubernetes" {
  config_path = abspath("${path.root}/../output/kubeconfig")
}

provider "null" {}
