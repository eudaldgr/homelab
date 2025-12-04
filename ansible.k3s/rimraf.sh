#!/bin/sh -e

ANSIBLE_CONFIG=./ansible.cfg \
ansible-playbook rimraf.yaml "$@"
