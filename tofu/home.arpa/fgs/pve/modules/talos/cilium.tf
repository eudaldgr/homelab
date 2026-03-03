data "helm_template" "cilium" {
  name         = "cilium"
  namespace    = "kube-system"
  repository   = "https://helm.cilium.io/"
  chart        = "cilium"
  version      = var.cilium_version
  kube_version = var.kubernetes_version

  values = [
    var.cilium_values
  ]
}

locals {
  cilium_patch = yamlencode({
    cluster = {
      inlineManifests = [{
        name     = "cilium"
        contents = data.helm_template.cilium.manifest
      }]
    }
  })
}
