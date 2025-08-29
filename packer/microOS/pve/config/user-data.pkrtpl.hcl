#cloud-config
ssh_pwauth: false
users:
  - name: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, wheel
    ssh_authorized_keys:
      - ${ssh_key}
write_files:
  - path: /etc/cloud/cloud.cfg.d/99-default-user.cfg
    content: |
      #cloud-config
      system_info:
        default_user:
          sudo: ALL=(ALL) NOPASSWD:ALL
          groups: users, wheel
          shell: /bin/bash
  - path: /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    content: |
      #cloud-config
      network:
        config: disabled
  - path: /etc/cloud/cloud.cfg.d/98-use-networkmanager.cfg
    content: |
      #cloud-config
      system_info:
        network:
          renderers: ['network-manager']
growpart:
  mode: auto
  devices: ['/', '/var']