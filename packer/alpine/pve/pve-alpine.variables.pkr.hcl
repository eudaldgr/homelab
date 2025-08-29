// Alpine Linux cloud image variables

locals {
  user = "alpine"

  alpine_cloud_img_name     = "nocloud_alpine-${var.alpine_version}-x86_64-uefi-cloudinit-r0.qcow2"
  alpine_cloud_img_url      = "https://dl-cdn.alpinelinux.org/alpine/v${join(".", slice(split(".", var.alpine_version), 0, 2))}/releases/cloud/${local.alpine_cloud_img_name}"

  write_image = <<-EOT
    set -ex
    echo 'Alpine image loaded, writing to disk...'
    doas qemu-img dd -f qcow2 -O raw bs=4M if=/tmp/${local.alpine_cloud_img_name} of=/dev/sda
    echo 'Image successfully written to disk'
    doas sync
  EOT

  copy_ssh_keys = <<-EOT
    set -ex
    echo 'Mounting disk...'
    doas partprobe /dev/sda
    doas mount -t ext4 /dev/sda2 /mnt
    echo 'Copying SSH keys...'
    doas mkdir -p /mnt/home/${local.user}/.ssh
    echo '${file("${var.ssh_public_key_file}")}' | doas tee -a /mnt/home/${local.user}/.ssh/authorized_keys
    doas chmod 600 /mnt/home/${local.user}/.ssh/authorized_keys
    doas chown -R ${local.user}:${local.user} /mnt/home/${local.user}/.ssh/authorized_keys
    echo 'Unmounting disk...'
    doas umount /mnt
    echo 'SSH keys copied successfully'
    doas sync && doas reboot
  EOT

  install_packages = <<-EOT
    set -ex
    echo 'Reboot successful, installing needed packages and doing some configurations...'
    doas apk update
    doas apk add --no-cache qemu-guest-agent
    echo 'Enabling qemu-guest-agent service...'
    doas rc-update add qemu-guest-agent default
    echo 'Enable keepenv on doas...'
    echo 'permit keepenv nopass :wheel' | doas tee /etc/doas.d/wheel.conf
    doas sync && doas reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo 'Reboot successful, cleaning-up...'
    echo 'Removing SSH host keys...'
    doas rm -rf /etc/ssh/ssh_host_* /home/${local.user}/.ssh
    doas passwd --lock root
    doas deluser --remove-home ${local.user}
  EOT
}