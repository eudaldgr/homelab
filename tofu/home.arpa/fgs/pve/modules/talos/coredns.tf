data "external" "coredns_kustomize" {
  program = [
    "sh", "-c",
    "kustomize build ${local.k8s.base_dir}/infrastructure/network/coredns --enable-helm | jq -Rs '{manifest: .}'"
  ]
}

locals {
  coredns_patch = yamlencode({
    cluster = {
      inlineManifests = [{
        name     = "coredns"
        contents = data.external.coredns_kustomize.result.manifest
      }]
    }
  })
}
