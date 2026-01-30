# K8s-Bootstrap-Apps Role

Bootstraps Day 0 applications including ArgoCD and required secrets.

## Description

This role:
- Creates required namespaces (shared-services, istio-system, security, argocd)
- Creates secrets for Cloudflare, Vault, SeaweedFS
- Installs ArgoCD
- Configures ArgoCD for Helm support in Kustomize
- Registers Git repositories
- Deploys the root ArgoCD Application (App of Apps pattern)

## Requirements

- Kubernetes cluster must be running
- kubectl configured on control plane
- Git repositories must be accessible
- SSH keys for private repositories

## Role Variables

Available variables with default values (see `defaults/main.yaml`):

```yaml
# ArgoCD configuration
argocd_version: "v3.2.3"
argocd_namespace: argocd
argocd_server_readiness_retries: 30
argocd_server_readiness_delay: 10

# Wave delay for ArgoCD sync
argocd_sync_wave_delay: "10"

# Git repository URLs
git_repo_url: "https://github.com/danyalahmed/dac-lab.git"
git_private_repo_url: "git@github.com:danyalahmed/dac-lab-private.git"

# Root application configuration
root_app_name: root-app
root_app_path: kubernetes/bootstrap
root_app_revision: main
```

Required secrets (in vault):
```yaml
cloudflare_api_token: "xxx"
seaweedfs_vault_secret_key: "xxx"
seaweedfs_postgres_password: "xxx"
seaweedfs_metadata_backup_secret_key: "xxx"
```

## Dependencies

- k8s-setup role

## Example Playbook

```yaml
- hosts: controlplanes
  become: false
  roles:
    - k8s-bootstrap-apps
```

## Tags

- `kubernetes` - Kubernetes resources
- `namespaces` - Namespace creation
- `secrets` - Secret management
- `argocd` - ArgoCD installation
- `config` - Configuration
- `git` - Git repository setup
- `apps` - Application deployment
- `bootstrap` - Bootstrap phase
- `istio` - Istio namespace
- `cloudflare` - Cloudflare secrets
- `vault` - Vault secrets
- `seaweedfs` - SeaweedFS secrets
- `postgres` - Postgres secrets
- `backup` - Backup secrets
- `kustomize` - Kustomize configuration
- `tls` - TLS configuration

## Usage Examples

```bash
# Full bootstrap
ansible-playbook site.yaml --tags bootstrap

# Only install ArgoCD
ansible-playbook site.yaml --tags argocd

# Only create secrets
ansible-playbook site.yaml --tags secrets

# Recreate namespaces
ansible-playbook site.yaml --tags namespaces
```

## ArgoCD Access

After installation, get the initial admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## License

MIT
