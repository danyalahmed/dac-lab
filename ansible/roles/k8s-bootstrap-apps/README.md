# K8s-Bootstrap-Apps Role

Bootstraps Day 0 applications and required secrets for the Kubernetes cluster.

## Description

This role:
- Creates required namespaces (shared-services, istio-system, security)
- Creates secrets for Cloudflare, Vault, SeaweedFS

## Requirements

- Kubernetes cluster must be running
- kubectl configured on control plane

## Role Variables

Available variables with default values (see `defaults/main.yaml`):

```yaml
# Git repository URLs (for future use with GitOps)
git_repo_url: "https://github.com/danyalahmed/dac-lab.git"
git_private_repo_url: "git@github.com:danyalahmed/dac-lab-private.git"
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
- `bootstrap` - Bootstrap phase
- `istio` - Istio namespace
- `cloudflare` - Cloudflare secrets
- `vault` - Vault secrets
- `seaweedfs` - SeaweedFS secrets
- `postgres` - Postgres secrets
- `backup` - Backup secrets
- `security` - Security namespace

## Usage Examples

```bash
# Full bootstrap
ansible-playbook site.yaml --tags bootstrap

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
