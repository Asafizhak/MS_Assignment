#!/bin/bash

# Quick AKS Infrastructure Management Script
# Provides easy deployment and destruction for cost savings

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if infrastructure exists
check_infrastructure() {
    if terraform show -json 2>/dev/null | grep -q "azurerm_kubernetes_cluster"; then
        return 0  # Infrastructure exists
    else
        return 1  # No infrastructure
    fi
}

# Function to show current status
show_status() {
    print_status "Checking current infrastructure status..."
    
    if check_infrastructure; then
        print_status "Infrastructure is currently DEPLOYED"
        echo ""
        echo "Current resources:"
        terraform output 2>/dev/null || echo "  (Run 'terraform init' if you see errors)"
        echo ""
        print_warning "Monthly cost: ~\$55 (development) or ~\$160 (production)"
    else
        print_success "Infrastructure is currently DESTROYED"
        print_success "Monthly cost: \$0"
    fi
}

# Function to deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying AKS + ACR infrastructure..."
    
    if check_infrastructure; then
        print_warning "Infrastructure already exists!"
        read -p "Do you want to redeploy? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            print_status "Deployment cancelled"
            return
        fi
    fi
    
    print_status "Initializing Terraform..."
    make init
    
    print_status "Deploying development environment..."
    make dev-deploy-all
    
    print_success "Infrastructure deployed successfully!"
    print_success "You can now use your AKS cluster and ACR"
    echo ""
    echo "Useful commands:"
    echo "  make aks-info          # Show cluster information"
    echo "  make nginx-status      # Check ingress status"
    echo "  make acr-integration   # Setup ACR integration if needed"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    print_warning "This will DESTROY all infrastructure and data!"
    print_warning "You will lose:"
    echo "  - AKS cluster and all workloads"
    echo "  - ACR and all container images"
    echo "  - Virtual network and load balancers"
    echo "  - All Kubernetes data and configurations"
    echo ""
    
    if ! check_infrastructure; then
        print_success "Infrastructure is already destroyed"
        return
    fi
    
    read -p "Are you sure you want to destroy everything? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_status "Destruction cancelled"
        return
    fi
    
    print_status "Destroying infrastructure..."
    make dev-destroy
    
    print_success "Infrastructure destroyed successfully!"
    print_success "Monthly cost is now \$0"
}

# Function to show cost information
show_costs() {
    echo ""
    echo "💰 COST BREAKDOWN"
    echo "=================="
    echo ""
    echo "When DEPLOYED:"
    echo "  Development:  ~\$55/month"
    echo "  Production:   ~\$160/month"
    echo ""
    echo "When DESTROYED: \$0/month ✅"
    echo ""
    echo "💡 Best practice: Destroy when not actively using"
    echo "   - Overnight: Save ~\$2-5"
    echo "   - Weekends: Save ~\$15-30"
    echo "   - Extended breaks: Save hundreds"
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "🚀 AKS Infrastructure Quick Manager"
    echo "=================================="
    echo ""
    show_status
    echo ""
    echo "Available actions:"
    echo "  1) Deploy infrastructure (AKS + ACR + NGINX)"
    echo "  2) Destroy infrastructure (save costs)"
    echo "  3) Show current status"
    echo "  4) Show cost information"
    echo "  5) Exit"
    echo ""
}

# Main script
main() {
    while true; do
        show_menu
        read -p "Choose an action (1-5): " choice
        
        case $choice in
            1)
                deploy_infrastructure
                ;;
            2)
                destroy_infrastructure
                ;;
            3)
                show_status
                ;;
            4)
                show_costs
                ;;
            5)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-5."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    print_error "This script must be run from the Terraform project directory"
    print_error "Please cd to the directory containing main.tf"
    exit 1
fi

# Run main function
main