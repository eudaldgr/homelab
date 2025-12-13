#cloud-config
ssh_pwauth: false
ssh_authorized_keys:
  - ${ssh_key}
growpart:
  mode: auto
  devices: ['/', '/var']