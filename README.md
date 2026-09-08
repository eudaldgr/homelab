<div align="center">

# Eudald's Homelab

_GitOps-managed home infrastructure powered by Talos, Kubernetes, OpenTofu, Flux CD, and Cilium._

</div>

<div align="center">

  [![Talos](https://kromgo.eudald.gr/badges/talos_version)](https://talos.dev)&nbsp;&nbsp;
  [![Kubernetes](https://kromgo.eudald.gr/badges/kubernetes_version)](https://kubernetes.io)&nbsp;&nbsp;
  [![Flux](https://kromgo.eudald.gr/badges/flux_version)](https://fluxcd.io)

</div>

<div align="center">

  [![Nodes](https://kromgo.eudald.gr/badges/cluster_node_count)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![Pods](https://kromgo.eudald.gr/badges/cluster_pod_count)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![CPU](https://kromgo.eudald.gr/badges/cluster_cpu_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![Memory](https://kromgo.eudald.gr/badges/cluster_memory_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![Power](https://kromgo.eudald.gr/badges/cluster_power_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![Age](https://kromgo.eudald.gr/badges/cluster_birth_age)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
  [![Uptime](https://kromgo.eudald.gr/badges/cluster_uptime_age)](https://github.com/home-operations/kromgo)

</div>

---

## Overview

This repository is the source of truth for my homelab: virtual machines, Talos
bootstrap, Kubernetes platform controllers, applications, secrets, backups, DNS,
and selected services that still run outside the cluster.

The operating model is deliberately boring:

1. OpenTofu creates and bootstraps the infrastructure.
1. Talos runs Kubernetes on Proxmox VMs.
1. Flux CD reconciles the desired state from `kubernetes/`.
1. Controllers handle networking, storage, certificates, databases, policy, and backups.

---

## Kubernetes

The active cluster is a six-node Talos Kubernetes deployment on Proxmox VE.

| Role | Nodes |
| --- | --- |
| Control plane | `ctrl-01`, `ctrl-02`, `ctrl-03` |

The Kubernetes API is exposed at `https://10.1.20.50:6443`. Local read-only
inspection uses the generated kubeconfig:

```bash
export KUBECONFIG=./tofu/home.arpa/fgs/pve/output/kubeconfig
kubectl get nodes -o wide
flux get kustomizations -A
```

The `Targets` badge counts Prometheus scrape targets that are currently up. It
is a monitoring signal, not a count of pods or public services.

### Core Components

| Area | Components |
| --- | --- |
| GitOps | Flux CD, Kustomize, Helm Controller |
| Networking | Cilium, Gateway API, LB IPAM, BGP, L2 announcement, ExternalDNS with AdGuard webhook |
| Ingress and tunnels | HTTPRoute, TLS passthrough, Pocket ID, Newt/Pangolin |
| Secrets | Infisical and SOPS for local encrypted files |
| Storage | Proxmox CSI on Ceph SSD and local ZFS, NFS for selected shared data |
| Databases | CloudNativePG with barman-cloud ObjectStore backups |
| Backups | Kopiur volume snapshots and CloudNativePG object-store backups |
| Observability and policy | kube-prometheus-stack, Hubble, Falco, Gatekeeper, Kyverno |

---

## GitOps

Flux bootstraps from `kubernetes/flux/cluster` and reconciles the platform and
applications under `kubernetes/apps`. Each deployable component owns a leaf
`Kustomization` and its manifests.

```bash
flux get sources git -A
flux get kustomizations -A
kustomize build kubernetes/apps/network/omada/app
```

```mermaid
flowchart TD
  repo["Git repository"] --> flux["Flux CD"]
  flux --> applications["kubernetes/apps"]
  applications --> platform["Platform controllers"]
  applications --> workloads["User-facing workloads"]
  platform --> cluster["Talos Kubernetes"]
  workloads --> cluster
```

---

## Infrastructure

The Proxmox Kubernetes path is split into three OpenTofu stages.

| Stage | Path | Responsibility |
| --- | --- | --- |
| Cluster | `tofu/home.arpa/fgs/pve/stack.cluster/` | Proxmox resources, VM definitions, DNS, storage, ACLs |
| Talos | `tofu/home.arpa/fgs/pve/stack.talos/` | Talos machine config, Kubernetes bootstrap, Cilium bootstrap, kubeconfig output |
| Kubernetes | `tofu/home.arpa/fgs/pve/stack.k8s/` | Kubernetes bootstrap resources |

Additional infrastructure lives in:

- `tofu/backblaze/homelab/` for backup buckets.
- `tofu/hetzner/homelab/` for Hetzner resources.
- `ansible/` for host preparation.
- `compose/ds920plus/prod/` for Compose workloads managed around Komodo and Pangolin.

---

## Repository

```text
.
├── ansible/      # Host preparation for container hosts, Komodo, and Pangolin
├── compose/      # Compose stacks for ds920plus, split into prod and archive
├── coreboot/     # Coreboot firmware work
├── komodo/       # Komodo resources: servers, repos, syncs, actions, builders
├── kubernetes/   # Kubernetes desired state reconciled by Flux CD
├── packer/       # Packer templates and variables
├── scripts/      # Local operator helpers
├── secrets/      # Sensitive material
└── tofu/         # OpenTofu stacks and modules
```

---

## Operations

Useful read-only checks:

```bash
export KUBECONFIG=./tofu/home.arpa/fgs/pve/output/kubeconfig

flux get kustomizations -A
kubectl get gateway,httproute -A -o wide
kubectl get storageclass,pvc -A
kubectl get clusters.postgresql.cnpg.io -A -o wide
kubectl get snapshotschedules.kopiur.home-operations.com -A
```

OpenTofu validation is run per stack:

```bash
tofu -chdir=tofu/home.arpa/fgs/pve/stack.cluster validate
tofu -chdir=tofu/home.arpa/fgs/pve/stack.talos validate
tofu -chdir=tofu/home.arpa/fgs/pve/stack.k8s validate
```

---

## Safety

This repository controls real infrastructure.

- Prefer GitOps over manual cluster mutation.
- Treat `./deploy` as unsafe notes, not as a normal deployment command.
- Do not commit plaintext secrets, kubeconfigs, private keys, tfstate, or local environment files.
- Do not modify encrypted secret material unless that is the explicit task.

---

## Inspiration

The layout is inspired by the home-operations community, especially repositories
that keep infrastructure understandable by making the current state visible at a
glance. The implementation here is tailored to this cluster's actual Proxmox,
Talos, Cilium, Proxmox CSI, Flux CD, Kopiur, and Compose setup.
