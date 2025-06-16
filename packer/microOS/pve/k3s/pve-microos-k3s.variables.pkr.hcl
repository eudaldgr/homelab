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
    "podman",
    "qemu-guest-agent"
  ], var.packages_to_install))

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

  install_packages = <<-EOT
    set -ex
    echo 'Reboot successful, installing needed packages and doing some configurations...'
    sudo timedatectl set-timezone Europe/Madrid
    sudo sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
    sudo transactional-update run sh -c '
        zypper refresh
        zypper dup -y
        zypper install -y ${local.needed_packages}
        grub2-mkconfig > /boot/grub2/grub.cfg
    '
    curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh -
    sleep 1 && sudo udevadm settle && sudo reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo 'Reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    sudo rm -rf /etc/ssh/ssh_host_*
    echo 'Make sure to use NetworkManager'
    sudo touch /etc/NetworkManager/NetworkManager.conf
    sudo userdel -r ${var.user} || true
    sleep 1 && sudo udevadm settle
  EOT
}