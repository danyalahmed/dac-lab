# Kubernetes Cluster Ansible Automation

This Ansible project automates the deployment and configuration of a Kubernetes cluster with Calico networking, ArgoCD GitOps, and supporting infrastructure.

## Architecture

- **Control Plane**: Single node running Kubernetes API server, etcd, and control plane components
- **Workers**: Multiple worker nodes for running workloads
- **Networking**: Calico CNI with VXLAN overlay
- **GitOps**: ArgoCD for application deployment
- **Service Mesh**: Istio in ambient mode

## Prerequisites

### Control Machine
- Ansible 2.15+ 
- Python 3.8+
- kubectl (for ArgoCD installation)
- helm 3+ (for CSR approver)

### Target Nodes
- Ubuntu 22.04 (Jammy) or Ubuntu 24.04 (Noble)
- SSH access with sudo privileges
- Minimum 2 CPU cores
- Minimum 2GB RAM (4GB+ recommended)
- Minimum 20GB disk space

## Quick Start

1. **Configure Inventory**
   ```bash
   # Edit inventory files with your node IPs
   vim inventory/hosts.yaml
   vim inventory/hosts.private.yaml
   ```

2. **Set Variables**
   ```bash
   # Configure cluster settings
   vim group_vars/all/main.yaml
   
   # Configure secrets (or use ansible-vault)
   vim group_vars/all/vault.yaml
   ```

3. **Run Playbook**
   ```bash
   # Full cluster deployment
   ansible-playbook site.yaml
   
   # Or use tags for specific phases
   ansible-playbook site.yaml --tags setup
   ansible-playbook site.yaml --tags bootstrap
   ```

## Playbook Structure

### Main Playbook: `site.yaml`

The playbook consists of several phases executed in order:

1. **Setup Phase** (`--tags setup`)
   - Prerequisites installation
   - Firewall configuration
   - Control plane initialization
   - Worker node joining
   - Storage configuration

2. **Bootstrap Phase** (`--tags bootstrap`)
   - ArgoCD installation
   - Secret creation
   - GitOps repository configuration

3. **Final Configuration** (`--tags final`)
   - DNS configuration
   - System optimizations

## Roles

### prerequisites
Installs and configures system requirements:
- System package updates
- Python dependencies
- Containerd runtime
- Kubernetes packages (kubeadm, kubelet, kubectl)
- Kernel modules and sysctl parameters
- Swap disable

**Tags**: `packages`, `swap`, `kernel`, `containerd`, `kubernetes`, `network`

### firewall
Configures UFW firewall rules for Kubernetes:
- SSH access
- Kubernetes API and etcd ports
- CNI networking ports (Calico)
- Service mesh ports (Istio)
- NodePort ranges
- NFS for storage

**Tags**: `firewall`, `ssh`, `controlplane`, `workers`, `networking`, `calico`, `istio`

### k8s-setup
Initializes the Kubernetes control plane:
- Kubeadm cluster initialization
- Kubeconfig setup
- CoreDNS configuration
- Calico CNI installation
- Certificate signing automation

**Tags**: `kubernetes`, `init`, `coredns`, `calico`, `csr`

### k8s-join-workers
Joins worker nodes to the cluster:
- Token generation
- Node joining
- Label application

**Tags**: `kubernetes`, `workers`, `join`, `labels`

### expand-lv
Expands logical volumes on worker nodes:
- LVM volume expansion
- Filesystem resize
- Storage verification

**Tags**: `storage`, `lvm`

### k8s-bootstrap-apps
Installs Day 0 applications:
- Namespace creation
- Secret management
- ArgoCD installation
- Git repository configuration
- Root application deployment

**Tags**: `kubernetes`, `argocd`, `secrets`, `bootstrap`

### final-touches
Final system configuration:
- CoreDNS integration with systemd-resolved
- Local path provisioner setup

**Tags**: `dns`, `configuration`, `storage`

## Tag Usage Examples

```bash
# Run only prerequisites
ansible-playbook site.yaml --tags prerequisites

# Setup firewall only
ansible-playbook site.yaml --tags firewall

# Initialize control plane without networking
ansible-playbook site.yaml --tags init --skip-tags calico

# Install only ArgoCD
ansible-playbook site.yaml --tags argocd

# Update DNS configuration
ansible-playbook site.yaml --tags dns

# Multiple tags
ansible-playbook site.yaml --tags "kubernetes,networking"
```

## Available Tags

### Phase Tags
- `setup` - All setup phase tasks
- `bootstrap` - Application bootstrapping
- `final` - Final configuration

### Component Tags
- `packages` - Package installation/updates
- `kubernetes` - Kubernetes-specific tasks
- `firewall` - Firewall rules
- `networking` - Network configuration
- `storage` - Storage configuration
- `secrets` - Secret management
- `dns` - DNS configuration

### Service Tags
- `containerd` - Container runtime
- `calico` - CNI networking
- `istio` - Service mesh
- `argocd` - GitOps tooling
- `vault` - Secret management
- `seaweedfs` - S3-compatible storage

## Configuration

### Important Variables

**Kubernetes Version** (`group_vars/all/main.yaml`):
```yaml
kubernetes_version: "1.35.0"
kubernetes_version_full: "1.35.0-1.1"
kubernetes_version_short: "1.35"
```

**Network Configuration** (`group_vars/all/main.yaml`):
```yaml
pod_network_cidr: "10.240.0.0/16"
```

**Component Versions** (`group_vars/all/main.yaml`):
```yaml
argocd_version: "v3.2.3"
calico_version: "v3.31.3"
kubelet_csr_approver_version: "1.2.12"
```

### Secrets Management

Use Ansible Vault for sensitive data:
```bash
# Encrypt vault file
ansible-vault encrypt group_vars/all/vault.yaml

# Run with vault password
ansible-playbook site.yaml --ask-vault-pass

# Use vault password file
ansible-playbook site.yaml --vault-password-file ~/.vault_pass
```

## Troubleshooting

### Check Ansible Connection
```bash
ansible all -m ping
```

### Test Specific Role
```bash
ansible-playbook site.yaml --tags prerequisites --check
```

### Run in Verbose Mode
```bash
ansible-playbook site.yaml -vvv
```

### View Facts
```bash
ansible all -m setup
```

## Maintenance

### Upgrade Kubernetes
1. Update versions in `group_vars/all/main.yaml`
2. Run prerequisites to update packages:
   ```bash
   ansible-playbook site.yaml --tags kubernetes,packages
   ```

### Reconfigure Firewall
```bash
ansible-playbook site.yaml --tags firewall
```

### Update ArgoCD
1. Update version in `group_vars/all/main.yaml`
2. Run bootstrap:
   ```bash
   ansible-playbook site.yaml --tags argocd
   ```

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── site.yaml               # Main playbook
├── group_vars/
│   └── all/
│       ├── main.yaml       # Common variables
│       └── vault.yaml      # Encrypted secrets
├── inventory/
│   ├── hosts.yaml          # Inventory structure
│   ├── hosts.private.yaml  # Private IPs
│   ├── group_vars/         # Group-specific vars
│   └── host_vars/          # Host-specific vars
├── roles/                  # Ansible roles
└── templates/              # Jinja2 templates
```

## Security Considerations

1. **SSH Keys**: Use SSH keys, not passwords
2. **Vault Encryption**: Encrypt all sensitive variables
3. **Firewall**: All roles configure strict firewall rules
4. **TLS**: Kubernetes components use TLS by default
5. **RBAC**: Kubernetes RBAC is enabled
6. **Secret Management**: Secrets are logged with `no_log: true`

## License

MIT

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review Ansible verbose output (-vvv)
