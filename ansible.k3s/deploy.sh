#!/bin/sh -e

ANSIBLE_CONFIG=./ansible.cfg \
ansible-playbook k3s-cluster.yaml "$@"
