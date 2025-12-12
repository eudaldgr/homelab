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
    "udica",
    "fail2ban",
    "nfs-utils",
    "curl",
    "wget",
    "podman",
    "fuse-overlayfs",
    "passt",
    "systemd-container",
    "libcap2",
    "iptables",
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

    transactional-update --non-interactive --continue setup-selinux
    transactional-update --continue run bash -c 'echo "-F" > /etc/selinux/.autorelabel'
    systemctl enable fail2ban

    # Write configs from Packer host into the guest
    cat > /etc/fail2ban/jail.local <<'EOF'
${file("${abspath(path.root)}/files/fail2ban-jail.local")}
EOF

    cat > /etc/modules-load.d/50-hcloud.conf <<'EOF'
${file("${abspath(path.root)}/files/podman-modules.conf")}
EOF

    cat > /etc/sysctl.d/50-hcloud.conf <<'EOF'
${file("${abspath(path.root)}/files/podman-sysctl.conf")}
EOF

    cat > /etc/containers/containers.conf <<'EOF'
[containers]
events_logger = "journald"
EOF

    mkdir -p /etc/rebootmgr.conf.d /etc/transactional-update.conf.d

    cat > /etc/rebootmgr.conf.d/50-hcloud.conf <<'EOF'
[rebootmgr]
window-start=02:00
window-duration=6h
strategy=best-effort
EOF

    echo 'REBOOT_METHOD=rebootmgr' > /etc/transactional-update.conf.d/50-reboot.conf

    systemctl disable podman.socket
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
    echo 'Clearing audit logs...'
    auditctl -D
    rm -f /var/log/audit/audit.log*
    echo 'Clearing journal logs...'
    journalctl --rotate
    journalctl --vacuum-time=1s
    sleep 1 && udevadm settle
  EOT
}