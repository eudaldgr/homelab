terraform {
  backend "s3" {
    bucket = "tofu"
    key    = "tofu/home.arpa/fgs/pve/stack.k8s.tfstate"
  }
}
