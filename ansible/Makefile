.PHONY: help validate deploy setup bootstrap cleanup health backup lint

# Default target
help:
	@echo ""
	@echo "Kubernetes Cluster Ansible Automation"
	@echo "====================================="
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  make validate       - Validate inventory and prerequisites"
	@echo "  make deploy         - Full cluster deployment (setup + bootstrap)"
	@echo "  make setup          - Setup cluster infrastructure only"
	@echo "  make bootstrap      - Bootstrap applications (ArgoCD)"
	@echo "  make health         - Check cluster health"
	@echo "  make backup         - Backup etcd and configs"
	@echo "  make cleanup        - Destroy cluster (DANGEROUS!)"
	@echo "  make lint           - Lint Ansible playbooks"
	@echo ""
	@echo "Tag-based targets:"
	@echo "  make firewall       - Configure firewall only"
	@echo "  make kubernetes     - Kubernetes-specific tasks only"
	@echo "  make argocd         - Install/update ArgoCD"
	@echo ""
	@echo "Environment variables:"
	@echo "  TAGS=<tags>         - Run specific tags"
	@echo "  LIMIT=<hosts>       - Limit to specific hosts"
	@echo "  CHECK=yes           - Run in check mode"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy"
	@echo "  make setup TAGS=prerequisites,firewall"
	@echo "  make setup CHECK=yes"
	@echo "  make deploy LIMIT=worker-01"
	@echo ""

validate:
	@echo "Validating prerequisites..."
	@ansible-playbook validate.yaml

deploy: validate
	@echo "Starting full deployment..."
	$(call run-playbook,site.yaml)

setup:
	@echo "Setting up cluster infrastructure..."
	$(call run-playbook,site.yaml --tags setup)

bootstrap:
	@echo "Bootstrapping applications..."
	$(call run-playbook,site.yaml --tags bootstrap)

health:
	@echo "Checking cluster health..."
	@ansible-playbook maintenance.yaml --tags health-check

backup:
	@echo "Creating backups..."
	@ansible-playbook maintenance.yaml --tags backup

cleanup:
	@echo "⚠️  WARNING: This will destroy the cluster!"
	@read -p "Type 'yes' to confirm: " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		ansible-playbook cleanup.yaml --extra-vars "confirm_cleanup=yes"; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Tag-based shortcuts
firewall:
	$(call run-playbook,site.yaml --tags firewall)

kubernetes:
	$(call run-playbook,site.yaml --tags kubernetes)

argocd:
	$(call run-playbook,site.yaml --tags argocd)

dns:
	$(call run-playbook,site.yaml --tags dns)

# Linting
lint:
	@echo "Linting Ansible playbooks..."
	@command -v ansible-lint >/dev/null 2>&1 || { echo "ansible-lint not found. Install with: pip install ansible-lint"; exit 1; }
	@ansible-lint site.yaml validate.yaml cleanup.yaml maintenance.yaml

# Internal function to run playbooks with options
define run-playbook
	ansible-playbook $(1) \
		$(if $(TAGS),--tags $(TAGS)) \
		$(if $(LIMIT),--limit $(LIMIT)) \
		$(if $(filter yes,$(CHECK)),--check) \
		$(if $(filter yes,$(VERBOSE)),-vvv)
endef
