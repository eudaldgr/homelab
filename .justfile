#!/usr/bin/env -S just --justfile

set minimum-version := '1.55.0'

set default-list
set default-script
set lazy
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# Bootstrap recipes
[group: 'Bootstrap']
mod bootstrap "bootstrap"

# Kubernetes recipes
[group: 'Kube']
mod kube "kubernetes"

# Talos recipes
[group: 'Talos']
mod talos "talos"

# OpenTofu recipes
[group: 'OpenTofu']
mod tofu "tofu"
