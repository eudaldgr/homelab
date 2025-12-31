// variables.pkr.hcl

locals {
  needed_packages = join(" ", concat([
    "fail2ban",
    "open-iscsi",
    "nfs-client",
    "util-linux",
    "e2fsprogs",
    "xfsprogs",
    "lvm2",
    "cryptsetup",
    "systemd-container",
    "podman",
    "docker-compose",
    "podman-docker",
    "age",
    "sops"
  ], var.packages_to_install))

  install_packages = <<-EOT
    set -ex
    transactional-update --continue pkg install -y ${local.needed_packages}
    sleep 1 && udevadm settle && reboot
  EOT

  configure_system = <<-EOT
    set -ex
    passwd -l root
    echo "PasswordAuthentication no" > /etc/ssh/sshd_config.d/50-homelab.conf
    transactional-update --non-interactive --continue setup-selinux
    transactional-update --continue run bash -c 'echo "-F" > /etc/selinux/.autorelabel'
    systemctl enable fail2ban

    # Enabling CPU, MEMORY, CPUSET, and I/O delegation
    # https://rootlesscontaine.rs/getting-started/common/cgroup2/
    mkdir -p /etc/systemd/system/user@.service.d
    cat > /etc/systemd/system/user@.service.d/delegate.conf <<'EOF'
[Service]
Delegate=cpu cpuset io memory pids
EOF

    # Write configs from Packer host into the guest
    cat > /etc/fail2ban/jail.local <<'EOF'
${file("${abspath(path.root)}/files/fail2ban-jail.local")}
EOF

    cat > /etc/sysctl.d/50-homelab.conf <<'EOF'
${file("${abspath(path.root)}/files/podman-sysctl.conf")}
EOF

    cat > /tmp/podman_homelab_selinux.te <<'EOF'
${file("${abspath(path.root)}/files/podman_homelab_selinux.te")}
EOF

    checkmodule -M -m -o /tmp/podman_homelab_selinux.mod /tmp/podman_homelab_selinux.te
    semodule_package -o /tmp/podman_homelab_selinux.pp -m /tmp/podman_homelab_selinux.mod
    semodule -i /tmp/podman_homelab_selinux.pp
    rm -f /tmp/podman_homelab_selinux.*

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
    systemctl enable iscsid

    echo 'All done, rebooting...'
    sleep 1 && sync && reboot
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
    sleep 1 && udevadm settle
  EOT
}
