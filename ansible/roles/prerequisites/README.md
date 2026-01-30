# Prerequisites Role

Installs and configures all prerequisites for a Kubernetes cluster.

## Description

This role prepares Ubuntu systems to run Kubernetes by:
- Updating system packages
- Installing required dependencies
- Configuring the containerd runtime
- Installing Kubernetes packages (kubeadm, kubelet, kubectl)
- Setting up kernel modules and sysctl parameters
- Disabling swap
- Configuring network optimizations for Calico

## Requirements

- Ubuntu 22.04 (Jammy) or 24.04 (Noble)
- Sudo access
- Internet connectivity for package downloads

## Role Variables

Available variables with default values (see `defaults/main.yaml`):

```yaml
# Additional packages to install (extends default list)
prerequisites_additional_packages: []

# Kubernetes versions
kubernetes_version: "1.35.0"
kubernetes_version_full: "1.35.0-1.1"
kubernetes_version_short: "1.35"

# Containerd configuration
containerd_state: started
containerd_enabled: true

# System optimization
swap_disable: true
```

## Dependencies

None

## Example Playbook

```yaml
- hosts: k8s_cluster
  become: true
  roles:
    - prerequisites
```

## Tags

- `packages` - Package installation and updates
- `update` - Package cache update
- `upgrade` - System upgrade
- `swap` - Swap configuration
- `system` - System configuration
- `kernel` - Kernel modules
- `modules` - Kernel module loading
- `sysctl` - Sysctl parameters
- `containerd` - Containerd installation and config
- `config` - Configuration files
- `services` - Service management
- `kubernetes` - Kubernetes packages
- `repo` - Repository configuration
- `network` - Network configuration
- `calico` - Calico-specific settings

## Usage Examples

```bash
# Run all prerequisites
ansible-playbook site.yaml --tags prerequisites

# Only install packages
ansible-playbook site.yaml --tags packages

# Only configure kernel
ansible-playbook site.yaml --tags kernel,sysctl

# Skip system upgrade
ansible-playbook site.yaml --tags prerequisites --skip-tags upgrade
```

## License

MIT
