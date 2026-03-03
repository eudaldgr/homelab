output "tofu_proxmox_api_token" {
  description = "API token string for Proxmox provider auth (id=secret)"
  value = format(
    "%s=%s",
    proxmox_virtual_environment_user_token.tofu.id,
    element(
      split("=", proxmox_virtual_environment_user_token.tofu.value),
      length(split("=", proxmox_virtual_environment_user_token.tofu.value)) - 1
    )
  )
  sensitive = true
}
