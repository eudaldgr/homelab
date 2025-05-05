// variables.pkr.hcl

locals {
  microos_img_name         = "openSUSE-MicroOS.x86_64-ContainerHost-OpenStack-Cloud.qcow2"
  microos_img_url          = "https://download.opensuse.org/tumbleweed/appliances/${local.microos_img_name}"
  microos_img_checksum_url = "${local.microos_img_url}.sha256"

  needed_packages = join(" ", concat([
    "restorecond",
    "policycoreutils",
    "policycoreutils-python-utils",
    "setools-console",
    "audit",
    "bind-utils",
    "wireguard-tools",
    "fuse",
    "open-iscsi",
    "nfs-client",
    "xfsprogs",
    "cryptsetup",
    "lvm2",
    "git",
    "cifs-utils",
    "bash-completion",
    "mtr",
    "tcpdump",
    "rebootmgr",
    "podman"
  ], var.packages_to_install))

  download_image = "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only"

  checksum_image = <<-EOT
    set -ex
    echo 'Verifying MicroOS image checksum...'
    cd /tmp
    grep ${local.microos_img_name} ${local.microos_img_name}.sha256 | sha256sum -c
  EOT

  write_image = <<-EOT
    set -ex
    echo 'MicroOS image loaded, writing to disk...'
    doas qemu-img dd -f qcow2 -O raw bs=4M if=/tmp/${local.microos_img_name} of=/dev/sda
    echo 'Image successfully written to disk, rebooting...'
    sleep 1 && doas sync && doas reboot
  EOT

  wait_for_cloudinit = <<-EOT
    set -ex
    sleep 30
    while pgrep -f transactional-update >/dev/null; do
        echo 'Waiting cloudinit transactional-update to finish...'
        sleep 10
    done
  EOT
  
  install_packages = <<-EOT
    set -ex
    echo 'First reboot successful, installing needed packages and doing some configurations...'
    sudo timedatectl set-timezone Europe/Madrid
    sudo transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && sudo udevadm settle && sudo reboot
  EOT
  
  clean_up = <<-EOT
    set -ex
    echo 'Second reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    sudo rm -rf /etc/ssh/ssh_host_*
    echo 'Make sure to use NetworkManager'
    sudo touch /etc/NetworkManager/NetworkManager.conf
    sudo userdel -r ${var.user} || true
    sleep 1 && sudo udevadm settle
  EOT

  # Cloud-init configuration
  cloud_init_meta_data = <<-EOT
    instance-id: microOS
  EOT

  cloud_init_user_data = <<-EOT
    #cloud-config
    ssh_pwauth: false
    users:
      - name: ${var.user}
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: users, wheel
        ssh_authorized_keys:
          - ${file("${var.ssh_public_key_file}")}
    write_files:
      - path: /etc/sysctl.d/90-k8s-net.conf
        content: |
          net.ipv4.conf.all.forwarding=1
          net.ipv6.conf.all.forwarding=1
      - path: /tmp/install
        content: |
          zypper refresh
          zypper dup -y
          zypper install -y qemu-guest-agent
          systemctl enable --now qemu-guest-agent
          sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
          grub2-mkconfig > /boot/grub2/grub.cfg
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
    runcmd:
      |
        transactional-update run sh -c "$(cat /tmp/install)" && \
        curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh - && \
        reboot
  EOT
}