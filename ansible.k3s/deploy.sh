#!/bin/sh -e

# Update Hetzner IP if using terraform/tofu
# Uncomment if you manage k3s-server-03 IP with terraform
# HCLOUD_IP=$(tofu -chdir=../infra/hetzner/homelab output -raw server_ip)
# sed "s/k3s-server-03 ansible_host=.*/k3s-server-03 ansible_host=${HCLOUD_IP}/" inventory/hosts.ini > _
# mv -f _ inventory/hosts.ini

ANSIBLE_CONFIG=./ansible.cfg \
ansible-playbook k3s-cluster.yml "$@"
