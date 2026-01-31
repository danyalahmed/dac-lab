# DAC Lab

Kubernetes homelab infrastructure using Ansible for cluster provisioning and FluxCD for GitOps-based application delivery.

## Structure

```
dac-lab/
├── ansible/                    # Day 0: Cluster provisioning
│   ├── site.yaml
│   ├── inventory/
│   │   ├── hosts.yaml
│   │   └── group_vars/
│   └── roles/
│       ├── prerequisites/
│       ├── k8s-setup/
│       ├── k8s-join-workers/
│       └── firewall/
│
└── kubernetes/                 # Day 1+: GitOps with FluxCD
    ├── flux-system/            # Flux core components
    ├── infrastructure/         # Platform services
    │   ├── cert-manager/
    │   ├── cloudnative-pg/
    │   ├── external-secrets/
    │   ├── istio/
    │   ├── metallb/
    │   ├── seaweedfs/
    │   └── vault/
    └── apps/                   # Applications
        ├── headlamp/
        ├── homeassistant/
        └── nextcloud/
```

### ansible/
Ansible playbooks and roles for Day 0 cluster bootstrapping:
- Kubernetes cluster setup (kubeadm)
- Storage provisioning (LVM expansion, NFS)
- Firewall configuration
- Initial cluster bootstrap apps

### kubernetes/
FluxCD GitOps configuration for Day 1+ operations:
- **flux-system/**: Core Flux components and cluster config
- **infrastructure/**: Platform services deployed in tiers
  - Tier 1: Storage (local-path, NFS CSI, metrics-server)
  - Tier 2: Core (MetalLB, cert-manager, CloudNative-PG)
  - Tier 3: Data & Secrets (SeaweedFS, Vault, External Secrets)
  - Tier 4: Service Mesh (Istio Gateway API, mesh, gateways)
- **apps/**: User applications (Headlamp, Home Assistant, Nextcloud)

## Usage

**Bootstrap cluster:**
```bash
cd ansible && make deploy
```

**Manage with Flux:**
```bash
flux get kustomizations
flux reconcile kustomization flux-system --with-source
```

Components are automatically deployed in dependency order via Flux Kustomizations with health checks and retry logic.
