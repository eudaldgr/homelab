terraform {
  backend "s3" {
    bucket = "tofu"
    key    = "tofu/home.arpa/fgs/pve/terraform.tfstate"
  }
}
