// variables.pkr.hcl

locals {
  needed_packages = join(" ", concat([
    "bash-completion",
    "bind-utils",
    "fail2ban",
    "iptables",
    "sudo",
    "udica",
    "podman",
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

    printf "%s\n" \
      "[DEFAULT]" \
      "bantime = 3600" \
      "findtime = 600" \
      "maxretry = 3" \
      "" \
      "[sshd]" \
      "enabled = true" \
      "port = 22" \
      "filter = sshd" \
      "logpath = /var/log/auth.log" \
      "maxretry = 3" \
      "bantime = 3600" \
      > /etc/fail2ban/jail.local

    printf "%s\n" \
      "ip_tables" \
      "ip6_tables" \
      "iptable_filter" \
      "iptable_mangle" \
      "nf_conntrack" \
      "xt_conntrack" \
      "xt_tcpudp" \
      "xt_TCPMSS" \
      "rtnl-link-wireguard" \
      "net-pf-16-proto-16-family-wireguard" \
      "nfnetlink-subsys-11" \
      "nft-expr-target" \
      "ipt_tcp" \
      "ipt_TCPMSS" \
      "wireguard" \
      > /etc/modules-load.d/50-hcloud.conf

    printf "%s\n" \
      "[containers]" \
      "events_logger = \"journald\"" \
      >> /etc/containers/containers.conf

    mkdir -p /etc/rebootmgr.conf.d /etc/transactional-update.conf.d

    printf "%s\n" \
      "[rebootmgr]" \
      "window-start=02:00" \
      "window-duration=6h" \
      "strategy=best-effort" \
      > /etc/rebootmgr.conf.d/50-hcloud.conf

    echo 'REBOOT_METHOD=rebootmgr' > /etc/transactional-update.conf.d/50-reboot.conf

    echo 'containers:300000:1048576' >> /etc/subuid
    echo 'containers:300000:1048576' >> /etc/subgid

    systemctl enable podman.socket
    systemctl enable podman-restart.service
    systemctl enable fail2ban
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
