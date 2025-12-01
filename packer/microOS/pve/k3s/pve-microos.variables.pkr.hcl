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
    "k3s-selinux",
    "helm",
    "python313-PyYAML",
    "python313-jsonpatch",
    "python313-kubernetes"
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

    # Write configs from Packer host into the guest
    cat > /etc/fail2ban/jail.local <<'EOF'
${file("${abspath(path.root)}/files/fail2ban-jail.local")}
EOF

    cat > /etc/modules-load.d/50-homelab.conf <<'EOF'
${file("${abspath(path.root)}/files/k3s-modules.conf")}
EOF

    cat > /etc/sysctl.d/50-homelab.conf <<'EOF'
${file("${abspath(path.root)}/files/k3s-sysctl.conf")}
EOF

    cat > /tmp/k3s_homelab_selinux.te <<'EOF'
${file("${abspath(path.root)}/files/k3s_homelab_selinux.te")}
EOF

    mkdir -p /etc/rancher/k3s /var/lib/rancher/k3s
    checkmodule -M -m -o /tmp/k3s_homelab_selinux.mod /tmp/k3s_homelab_selinux.te
    semodule_package -o /tmp/k3s_homelab_selinux.pp -m /tmp/k3s_homelab_selinux.mod
    semodule -i /tmp/k3s_homelab_selinux.pp
    setsebool -P virt_use_samba 1
    setsebool -P domain_kernel_load_modules 1
    rm -f /tmp/k3s_homelab_selinux.*

    echo 'Defaults    secure_path = /usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin' > /etc/sudoers.d/50-homelab

    mkdir -p /etc/transactional-update.conf.d
    echo 'REBOOT_METHOD=kured' > /etc/transactional-update.conf.d/50-homelab.conf
    systemctl disable rebootmgr
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
