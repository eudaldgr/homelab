locals {
  k8s = {
    base_dir = "${path.module}/../../../../../../k8s"
  }
  sealed_secrets_master_key_file = "${path.module}/../../../../../../secrets/sealed-secrets-master-keys.yaml"
}
