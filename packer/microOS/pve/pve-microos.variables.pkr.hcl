// variables.pkr.hcl

locals {
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
    grep ${local.microos_x86_img_name} ${local.microos_x86_img_name}.sha256 | sha256sum -c
  EOT

  write_image = <<-EOT
    set -ex
    echo 'MicroOS image loaded, writing to disk...'
    doas qemu-img dd -f qcow2 -O raw bs=4M if=/tmp/${local.microos_x86_img_name} of=/dev/sda
    echo 'Image successfully written to disk, rebooting...'
    sleep 1 && doas sync && doas reboot
  EOT

  install_packages = <<-EOT
    set -ex
    echo 'Reboot successful, installing needed packages and doing some configurations...'
    sudo timedatectl set-timezone Europe/Madrid
    sudo sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
    sudo transactional-update --continue shell <<-EOF
        grub2-mkconfig > /boot/grub2/grub.cfg
    EOF
    sudo transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && sudo udevadm settle && sudo reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo 'Reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    sudo rm -rf /etc/ssh/ssh_host_* /home/${var.user}/.ssh/authorized_keys
    echo 'Make sure to use NetworkManager'
    sudo touch /etc/NetworkManager/NetworkManager.conf
    sudo userdel -r ${var.user} || true
    sleep 1 && sudo udevadm settle
  EOT
}