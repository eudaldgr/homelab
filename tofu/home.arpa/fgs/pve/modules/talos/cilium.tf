data "external" "cilium_kustomize" {
  program = [
    "sh", "-c",
    "kustomize build ${local.k8s.base_dir}/infrastructure/network/cilium --enable-helm | jq -Rs '{manifest: .}'"
  ]
}

locals {
  cilium_patch = yamlencode({
    cluster = {
      inlineManifests = [{
        name     = "cilium"
        contents = data.external.cilium_kustomize.result.manifest
      }]
    }
  })
}
