# Contributing to Kubernetes Cluster Ansible

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:
- Ansible version
- Target OS version (Ubuntu version)
- Steps to reproduce
- Expected vs actual behavior
- Relevant error messages or logs

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:
- Clear description of the enhancement
- Use case and benefits
- Potential implementation approach

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly (see Testing section)
5. Lint your code (`make lint`)
6. Commit your changes with clear messages
7. Push to your fork
8. Open a Pull Request

## Development Guidelines

### Ansible Best Practices

- Use fully qualified collection names (FQCN)
  ```yaml
  # Good
  ansible.builtin.command:
  # Bad
  command:
  ```

- Add tags to all tasks
  ```yaml
  - name: Task name
    ansible.builtin.command: echo "hello"
    tags:
      - example
      - category
  ```

- Use `no_log: true` for sensitive data
  ```yaml
  - name: Create secret
    kubernetes.core.k8s:
      definition: "{{ secret_definition }}"
    no_log: true
  ```

- Set `changed_when` for read-only tasks
  ```yaml
  - name: Check status
    ansible.builtin.command: kubectl get nodes
    changed_when: false
  ```

- Explicit file ownership
  ```yaml
  - name: Create file
    ansible.builtin.copy:
      dest: /etc/config
      owner: root
      group: root
      mode: '0644'
  ```

### Role Structure

Each role should have:
```
role-name/
├── defaults/
│   └── main.yaml      # Default variables
├── handlers/
│   └── main.yaml      # Handlers
├── meta/
│   └── main.yaml      # Role metadata
├── tasks/
│   └── main.yaml      # Main tasks
├── templates/
│   └── *.j2           # Jinja2 templates
└── README.md          # Role documentation
```

### Variable Naming

- Use lowercase with underscores
- Prefix role-specific variables with role name
- Clear, descriptive names

```yaml
# Good
kubernetes_version: "1.35.0"
pod_network_cidr: "10.240.0.0/16"

# Bad
k8s_ver: "1.35.0"
pod_net: "10.240.0.0/16"
```

### Task Naming

- Start with a verb
- Be descriptive and specific
- Use sentence case

```yaml
# Good
- name: Install Kubernetes packages
- name: Configure CoreDNS for external DNS

# Bad
- name: install packages
- name: fix dns
```

## Testing

### Pre-Commit Checks

Before committing, run:
```bash
make lint              # Lint playbooks
make validate          # Validate configuration
```

### Testing Changes

1. **Syntax Check**
   ```bash
   ansible-playbook site.yaml --syntax-check
   ```

2. **Dry Run**
   ```bash
   ansible-playbook site.yaml --check
   ```

3. **Limited Deployment**
   ```bash
   ansible-playbook site.yaml --limit test-node
   ```

4. **Full Test**
   - Deploy to a test environment
   - Verify all functionality
   - Run health checks

### Test Environment

Recommended test setup:
- 1 control plane node
- 2 worker nodes
- Fresh Ubuntu 22.04 or 24.04 installations
- Isolated network (no production impact)

## Documentation

### Code Documentation

- Add comments for complex logic
- Document non-obvious decisions
- Include examples in role READMEs

### Updating Documentation

When making changes, update:
- Role README.md if changing role behavior
- Main README.md if adding new features
- CHANGELOG.md with your changes

## Release Process

1. Update CHANGELOG.md
2. Update version in relevant files
3. Test thoroughly
4. Create git tag
5. Document breaking changes

## Questions?

- Open an issue for questions
- Review existing issues and PRs
- Check documentation first

Thank you for contributing! 🎉
