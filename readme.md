# dac-lab

## Folder Structure

```text
dac-lab/
├── readme.md
├── ansible/                   # DAY 0: Cluster & Storage Bootstrap
│   ├── ansible.cfg
│   ├── site.yaml
│   ├── temp.yml
│   ├── group_vars/
│   │   └── all/
│   ├── inventory/
│   │   ├── hosts.yaml
│   │   ├── hosts.private.yaml  # for node IPs, kept private
│   │   ├── group_vars/
│   │   └── host_vars/
│   ├── roles/
│   │   ├── expand-lv/
│   │   ├── firewall/
│   │   ├── k8s-bootstrap-apps/
│   │   ├── k8s-join-workers/
│   │   ├── k8s-setup/
│   │   └── prerequisites/
│   └── templates/
│
├── kubernetes/                # DAY 1: GitOps Management
│   ├── bootstrap/             # The "Root" App-of-Apps
│   │   ├── infra.yaml
│   │   └── projects.yaml
│   └── infra/                 # Sync Wave 1: The Identity Layer
│       ├── seaweedfs.yaml
│       └── seaweedfs/
│           ├── base/
│           └── instances/
│               ├── primary/   # used for object store
│               └── secondary/ # used for PG backups (break chicken and egg cycle)
│
# TODO: more to follow
```
