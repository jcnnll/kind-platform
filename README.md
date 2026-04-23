# KIND Kubernetes Lab

## Overview

This project provides a reproducible local Kubernetes lab environment using KIND
to simulate a multi-node cluster.

It includes:

- Multi-node KIND cluster configuration
- Base platform setup (namespaces, RBAC, quotas, limits)
- Ingress controller (nginx)
- Local DNS using dnsmasq
- Trusted TLS using mkcert
- Sample workload (echo service) exposed via HTTPS

The goal is to provide a clean, deterministic starting point for building and
testing workloads against a realistic Kubernetes platform layer.

---

## Lab Structure

```
├── kind/                         # KIND cluster bootstrap configuration
│   └── cluster.yaml              # multi-node cluster definition
│
├── Makefile                      # primary orchestration entrypoint
│
├── platform/                     # core Kubernetes platform layer
│   ├── ingress/                  # ingress controller (nginx)
│   │   └── ingress-nginx.yaml
│   ├── limits/                   # container resource limits defaults
│   │   └── lab.yaml
│   ├── namespaces/               # base namespace definitions
│   │   └── lab.yaml
│   ├── quotas/                   # resource quotas per namespace
│   │   └── lab.yaml
│   └── rbac/                     # access control model
│       ├── lab-binding.yaml
│       ├── lab-role.yaml
│       └── lab-serviceaccount.yaml
│
├── scripts/                      # operational automation
│   └── bootstrap-tls.sh          # mkcert → k8s secret bootstrap
│
├── workloads/                    # example application layer (replaceable)
│   └── echo/
│       ├── deploy.yaml           # sample workload deployment
│       └── ingress.yaml          # sample ingress rule
│
├── README.md                     # platform documentation + usage guide
```

---

## Starter Lab Runtime Model

This lab provides a deterministic Kubernetes platform layer. Workloads are
deployed into the platform to validate DNS, ingress, TLS, and routing behavior.

The included echo API is only a sample workload used to verify platform functionality.

```

        ┌────────────────────────────┐
        │        Client (curl)       │
        │      any workload test     │
        └─────────────┬──────────────┘
                      │ DNS (dnsmasq)
                      ▼
        ┌────────────────────────────┐
        │  Local DNS Resolution      │
        │  *.lab → 127.0.0.1         │
        └─────────────┬──────────────┘
                      │
                      ▼
        ┌────────────────────────────┐
        │ Kubernetes Platform Layer  │
        │ KIND multi-node cluster    │
        │ ingress-nginx controller   │
        └─────────────┬──────────────┘
                      │
                      ▼
        ┌────────────────────────────┐
        │ Ingress Routing Layer      │
        │ host/path rules            │
        │ TLS termination (mkcert)   │
        └─────────────┬──────────────┘
                      │
                      ▼
        ┌────────────────────────────┐
        │ Kubernetes Service Layer   │
        │ service → pod routing      │
        └─────────────┬──────────────┘
                      │
                      ▼
        ┌────────────────────────────┐
        │ Workloads (examples)       │
        │ echo API (sample only)     │
        │ replaceable application    │
        └────────────────────────────┘

                                              
```

---

## Dependencies

The following must be installed on the host:

- docker
- kind
- kubectl
- mkcert
- dnsmasq

Notes:

- mkcert must be available in PATH
- dnsmasq must be installed via Homebrew (macOS) or system package manager

---

## DNS Configuration (dnsmasq)

This lab uses dnsmasq to resolve the `.lab` domain locally.

### 1. Configure dnsmasq

Create file:

/opt/homebrew/etc/dnsmasq.d/lab.conf

Contents:

address=/.lab/127.0.0.1

---

### 2. Configure system resolver (macOS)

Create file:

/etc/resolver/lab

Contents:

nameserver 127.0.0.1

---

### 3. Restart dnsmasq

brew services restart dnsmasq

---

### 4. Verify DNS

dig api.lab @127.0.0.1

Expected:

api.lab → 127.0.0.1

---

## TLS

TLS certificates are generated using mkcert and injected into Kubernetes
as a TLS secret.

- Certificates are generated at runtime (ephemeral)
- No persistent certificate storage is required
- Ingress uses the secret for HTTPS termination

---

## Usage

### Create cluster and deploy everything

`make up`

This will:

1. Create KIND cluster
2. Apply platform configuration
3. Install ingress controller
4. Generate TLS certificates
5. Deploy sample workload
6. Validate end-to-end routing

---

### Verify system manually

`curl https://api.lab`

Expected:

hello lab

---

### Platform checks (static)

`make check`

---

### Runtime validation (end-to-end)

`make validate`

---

### Destroy cluster

`make down`

---

## Notes

- No port-forwarding is used
- No manual /etc/hosts changes required
- No browser certificate trust configuration required
- All routing is done via ingress-nginx on localhost (ports 80/443)

---

## Purpose

This lab provides a clean foundation for:

- Testing Kubernetes workloads locally
- Practicing platform engineering concepts
- Validating ingress, TLS, and DNS behavior
- Simulating multi-node cluster environments

Clone or fork this repository to bootstrap local Kubernetes lab environments.

The included echo service is a minimal example used to validate platform behavior.
It is intended to be replaced with application-specific workloads.
