#!/usr/bin/env -S just --justfile

set minimum-version := '1.55.0'

set default-list
set default-script
set lazy
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

# Bootstrap Recipes
[group('Bootstrap')]
mod bootstrap "bootstrap"

# Kube Recipes
[group('Kube')]
mod kube "kubernetes"

# Talos Recipes
[group('Talos')]
mod talos "talos"

# OpenTofu Recipes
[group('OpenTofu')]
mod tofu "tofu"

[private]
log lvl msg *args:
    gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

# Render a minijinja template and resolve ${SECRET} references from Infisical (fails on any missing secret)
[private]
template file *args:
    infisical run \
        --domain=https://eu.infisical.com \
        --projectId=89d5ec5c-6201-4007-acc8-3f4748228396 \
        --env=prod --expand=false --silent \
        --path=/kubernetes/infisical \
        --path=/kubernetes/talos \
        -- bash -euo pipefail -c '
            rendered="$(minijinja-cli "$@")"
            for var in $(grep -oE "[$][{][A-Za-z0-9_]+[}]" <<< "${rendered}" | tr -d "\${}" | sort -u); do
                [[ -n "${!var:-}" ]] || { echo "Missing Infisical secret: ${var}" >&2; exit 1; }
            done
            envsubst <<< "${rendered}"
        ' _ "{{ file }}" {{ args }}
