// variables.pkr.hcl

locals {
  needed_packages = join(" ", concat([
    "bash-completion",
    "bind-utils",
    "qemu-guest-agent"
  ], var.packages_to_install))

  write_image = <<-EOT
    set -ex
    echo 'MicroOS image loaded, writing to disk... '
    qemu-img convert -p -f qcow2 -O host_device $(ls -a | grep -ie '^opensuse.*microos.*qcow2$') /dev/sda
    echo 'Image successfully written to disk, rebooting...'
    sleep 1 && udevadm settle && reboot
  EOT

  install_packages = <<-EOT
    set -ex
    echo "First reboot successful, installing needed packages..."
    transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && udevadm settle && reboot
  EOT

  configure_system = <<-EOT
    set -ex
    passwd -l root
    echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/50-hcloud.conf

    mkdir -p /etc/rebootmgr.conf.d /etc/transactional-update.conf.d

    cat > /etc/rebootmgr.conf.d/50-hcloud.conf <<'EOF'
[rebootmgr]
window-start=04:00
window-duration=2h
strategy=best-effort
EOF

    echo 'REBOOT_METHOD=rebootmgr' > /etc/transactional-update.conf.d/50-reboot.conf

    systemctl enable rebootmgr
    systemctl enable transactional-update.timer

    echo 'All done, rebooting...'
    sleep 1 && sync && reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo 'Reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    rm -rf /etc/ssh/ssh_host_* /root/.ssh /root/.bash_history
    rm -rf $(ls -a | grep -ie '^opensuse.*microos.*qcow2$')
    echo "Make sure to use NetworkManager"
    touch /etc/NetworkManager/NetworkManager.conf
    echo 'Clearing machine-id...'
    truncate -s 0 /etc/machine-id
    echo 'Clearing journal logs...'
    journalctl --rotate
    journalctl --vacuum-time=1s
    sleep 1 && udevadm settle
  EOT
}
