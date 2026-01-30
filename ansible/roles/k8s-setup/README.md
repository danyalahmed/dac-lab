# K8s-Setup Role

Initializes the Kubernetes control plane and installs the Calico CNI.

## Description

This role:
- Initializes the Kubernetes control plane with kubeadm
- Configures kubeconfig for the admin user
- Patches CoreDNS configuration
- Installs Calico CNI with Tigera operator
- Installs and configures Kubelet CSR Approver
- Handles certificate signing requests

## Requirements

- Prerequisites role must be run first
- Control plane node only
- Helm 3+ installed on control machine (for CSR approver)

## Role Variables

Available variables with default values (see `defaults/main.yaml`):

```yaml
# Kubernetes configuration
kubernetes_version: "1.35.0"
pod_network_cidr: "10.240.0.0/16"

# Calico version
calico_version: "v3.31.3"

# DNS servers for CoreDNS
desired_dns_servers: "1.1.1.1"

# CSR approver
kubelet_csr_approver_version: "1.2.12"
csr_approver_installed: false

# API server wait timeout
api_server_timeout: 300

# Calico operator wait settings
calico_operator_retries: 20
calico_operator_delay: 15
```

## Dependencies

- prerequisites role

## Example Playbook

```yaml
- hosts: controlplanes
  become: true
  roles:
    - k8s-setup
```

## Tags

- `kubernetes` - All Kubernetes tasks
- `init` - Cluster initialization
- `config` - Configuration tasks
- `apiserver` - API server related
- `kubeconfig` - Kubeconfig setup
- `coredns` - CoreDNS configuration
- `networking` - Network plugin
- `csr` - Certificate signing
- `calico` - Calico CNI
- `helm` - Helm operations

## Usage Examples

```bash
# Full control plane setup
ansible-playbook site.yaml --tags controlplane

# Initialize without CNI
ansible-playbook site.yaml --tags init --skip-tags calico

# Only configure CoreDNS
ansible-playbook site.yaml --tags coredns

# Reinstall Calico
ansible-playbook site.yaml --tags calico
```

## Bootstrap Flag

The role creates `/etc/kubernetes/.bootstrapped` to prevent re-initialization. Delete this file if you need to re-initialize the cluster.

## License

MIT
