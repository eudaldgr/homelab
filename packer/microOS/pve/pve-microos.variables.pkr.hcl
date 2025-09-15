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
    qemu-img dd -f qcow2 -O raw bs=4M if=/tmp/${local.microos_x86_img_name} of=/dev/sda
    echo 'Image successfully written to disk, rebooting...'
    sleep 1 && sync && reboot
  EOT

  install_packages = <<-EOT
    set -ex
    echo 'Reboot successful, installing needed packages and doing some configurations...'
    timedatectl set-timezone Europe/Madrid
    sed -i "s/GRUB_TIMEOUT=10/GRUB_TIMEOUT=1/g" /etc/default/grub
    transactional-update --continue shell <<-EOF
        grub2-mkconfig > /boot/grub2/grub.cfg
    EOF
    transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && udevadm settle && reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo 'Reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    rm -rf /etc/ssh/ssh_host_* /root/.ssh /root/.bash_history
    echo 'Clearing machine-id...'
    truncate -s 0 /etc/machine-id
    echo 'Clearing audit logs...'
    auditctl -D
    rm -f /var/log/audit/audit.log*
    echo 'Clearing journal logs...'
    journalctl --rotate
    journalctl --vacuum-time=1s
    echo 'Make sure to use NetworkManager'
    touch /etc/NetworkManager/NetworkManager.conf
    sleep 1 && udevadm settle
  EOT
}