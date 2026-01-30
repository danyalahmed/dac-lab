#!/usr/bin/env bash
# Quick deployment script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking requirements..."
    
    # Check Ansible
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "Ansible not found. Please install Ansible 2.15+"
        exit 1
    fi
    
    ANSIBLE_VERSION=$(ansible --version | head -n1 | sed -E 's/.*\[core ([0-9.]+)\].*/\1/' | grep -E '^[0-9]' || ansible --version | head -n1 | awk '{print $2}')
    log_info "Found Ansible version: $ANSIBLE_VERSION"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log_warn "kubectl not found. Required for ArgoCD installation."
    fi
    
    # Check helm
    if ! command -v helm &> /dev/null; then
        log_warn "helm not found. Required for CSR approver installation."
    fi
}

run_validation() {
    log_info "Running validation..."
    if ansible-playbook validate.yaml; then
        log_info "Validation passed ✓"
    else
        log_error "Validation failed ✗"
        exit 1
    fi
}

show_menu() {
    echo ""
    echo "Kubernetes Cluster Deployment"
    echo "=============================="
    echo ""
    echo "1) Full deployment (recommended)"
    echo "2) Setup only (infrastructure)"
    echo "3) Bootstrap only (applications)"
    echo "4) Validate only"
    echo "5) Health check"
    echo "6) Exit"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            log_info "Starting full deployment..."
            run_validation
            ansible-playbook site.yaml
            ;;
        2)
            log_info "Setting up infrastructure..."
            run_validation
            ansible-playbook site.yaml --tags setup
            ;;
        3)
            log_info "Bootstrapping applications..."
            ansible-playbook site.yaml --tags bootstrap
            ;;
        4)
            run_validation
            ;;
        5)
            log_info "Checking cluster health..."
            ansible-playbook maintenance.yaml --tags health-check
            ;;
        6)
            log_info "Exiting..."
            exit 0
            ;;
        *)
            log_error "Invalid option"
            exit 1
            ;;
    esac
}

# Main
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║  Kubernetes Cluster Deployment Tool   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    check_requirements
    
    if [ $# -eq 0 ]; then
        show_menu
    else
        case "$1" in
            deploy|full)
                run_validation
                ansible-playbook site.yaml
                ;;
            setup)
                run_validation
                ansible-playbook site.yaml --tags setup
                ;;
            bootstrap)
                ansible-playbook site.yaml --tags bootstrap
                ;;
            validate)
                run_validation
                ;;
            health)
                ansible-playbook maintenance.yaml --tags health-check
                ;;
            help|--help|-h)
                echo "Usage: $0 [deploy|setup|bootstrap|validate|health]"
                echo ""
                echo "Options:"
                echo "  deploy     - Full cluster deployment"
                echo "  setup      - Setup infrastructure only"
                echo "  bootstrap  - Bootstrap applications only"
                echo "  validate   - Validate configuration"
                echo "  health     - Check cluster health"
                echo ""
                ;;
            *)
                log_error "Unknown command: $1"
                log_info "Run '$0 help' for usage information"
                exit 1
                ;;
        esac
    fi
    
    log_info "Done!"
}

main "$@"
