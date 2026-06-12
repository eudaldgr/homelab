terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }
  }
}

provider "kubernetes" {
  config_path = abspath("${path.root}/../output/kubeconfig")
}

provider "null" {}
