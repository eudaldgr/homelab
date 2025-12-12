#!/bin/sh -e

HCLOUD_IP=$(tofu -chdir=../tofu/hetzner/homelab output -raw server_ip)

sed "s/pangolin01 ansible_host=.*/pangolin01 ansible_host=${HCLOUD_IP}/" inventory/hosts.ini > _
mv -f _ inventory/hosts.ini

ANSIBLE_CONFIG=./ansible.cfg \
ansible-playbook container-host.yml "$@"
