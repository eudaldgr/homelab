#!/bin/sh -e

export ANSIBLE_CONFIG=./ansible.cfg

if [ "$1" = "--pangolin" ]; then
  HCLOUD_IP=$(tofu -chdir=../tofu/hetzner/homelab output -raw server_ip)

  sed "s/pangolin01 ansible_host=.*/pangolin01 ansible_host=${HCLOUD_IP}/" inventory/hosts.ini > _
  mv -f _ inventory/hosts.ini

  shift
  ansible-playbook pangolin.yaml --skip-tags sops,age "$@"
else
  ansible-playbook containers-host.yaml "$@"
fi
