#!/usr/bin/env -S just --justfile

set default-list
set default-script
set lazy
set quiet
set shell := ['sh', '-eu', '-c']

# Kubernetes recipes
[group: 'Kube']
mod kube "kubernetes"
