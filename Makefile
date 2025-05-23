# Azure Container Registry and AKS Terraform Makefile
# Provides common commands for managing the Terraform infrastructure

.PHONY: help init plan apply destroy validate format clean setup aks-creds nginx-install

# Default target
help: ## Show this help message
	@echo "Azure Container Registry and AKS Terraform Commands"
	@echo "=================================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Run the setup script to configure the project
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

init: ## Initialize Terraform
	@echo "🏗️  Initializing Terraform..."
	@terraform init \
		-backend-config="resource_group_name=Storage_SG" \
		-backend-config="storage_account_name=msassignmenttfstate" \
		-backend-config="container_name=tfstate" \
		-backend-config="key=acr-demo.terraform.tfstate"

validate: ## Validate Terraform configuration
	@echo "✅ Validating Terraform configuration..."
	@terraform validate

format: ## Format Terraform files
	@echo "🎨 Formatting Terraform files..."
	@terraform fmt -recursive

plan: ## Create Terraform execution plan
	@echo "📋 Creating Terraform plan..."
	@terraform plan

apply: ## Apply Terraform configuration
	@echo "🚀 Applying Terraform configuration..."
	@terraform apply

apply-auto: ## Apply Terraform configuration without confirmation
	@echo "🚀 Applying Terraform configuration (auto-approve)..."
	@terraform apply -auto-approve

destroy: ## Destroy Terraform-managed infrastructure
	@echo "💥 Destroying Terraform infrastructure..."
	@terraform destroy

destroy-auto: ## Destroy infrastructure without confirmation
	@echo "💥 Destroying Terraform infrastructure (auto-approve)..."
	@terraform destroy -auto-approve

output: ## Show Terraform outputs
	@echo "📤 Terraform outputs:"
	@terraform output

state: ## Show Terraform state
	@echo "📊 Terraform state:"
	@terraform state list

clean: ## Clean Terraform files
	@echo "🧹 Cleaning Terraform files..."
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f terraform.tfstate*
	@rm -f *.tfplan

check: validate format ## Run validation and formatting checks
	@echo "✅ All checks passed!"

# Development targets
dev-plan: ## Plan with development variables
	@terraform plan -var-file="environments/dev.tfvars"

dev-apply: ## Apply with development variables
	@terraform apply -var-file="environments/dev.tfvars"

prod-plan: ## Plan with production variables
	@terraform plan -var-file="environments/prod.tfvars"

prod-apply: ## Apply with production variables
	@terraform apply -var-file="environments/prod.tfvars"

# ACR specific commands
acr-login: ## Login to Azure Container Registry
	@echo "🔐 Logging into ACR..."
	@ACR_NAME=$$(terraform output -raw acr_name 2>/dev/null || echo ""); \
	if [ -z "$$ACR_NAME" ]; then \
		echo "❌ ACR not deployed yet. Run 'make apply' first."; \
	else \
		az acr login --name $$ACR_NAME; \
	fi

acr-info: ## Show ACR information
	@echo "ℹ️  ACR Information:"
	@terraform output

# Security
security-scan: ## Run security scan on Terraform files
	@echo "🔍 Running security scan..."
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "⚠️  tfsec not installed. Install with: brew install tfsec"; \
	fi

# Documentation
docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table --output-file README-terraform.md .; \
	else \
		echo "⚠️  terraform-docs not installed. Install with: brew install terraform-docs"; \
	fi

# Cost estimation
cost: ## Estimate infrastructure costs
	@echo "💰 Estimating costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "⚠️  infracost not installed. Visit: https://www.infracost.io/docs/"; \
	fi

# AKS specific commands
aks-creds: ## Get AKS cluster credentials
	@echo "🔐 Getting AKS credentials..."
	@CLUSTER_NAME=$$(terraform output -raw aks_cluster_name 2>/dev/null || echo ""); \
	RG_NAME=$$(terraform output -raw resource_group_name 2>/dev/null || echo ""); \
	if [ -z "$$CLUSTER_NAME" ] || [ -z "$$RG_NAME" ]; then \
		echo "❌ AKS not deployed yet. Run 'make apply' first."; \
	else \
		az aks get-credentials --resource-group $$RG_NAME --name $$CLUSTER_NAME --overwrite-existing; \
		echo "✅ AKS credentials configured for kubectl"; \
	fi

aks-info: ## Show AKS cluster information
	@echo "ℹ️  AKS Cluster Information:"
	@terraform output | grep aks

aks-nodes: ## Show AKS cluster nodes
	@echo "🖥️  AKS Cluster Nodes:"
	@kubectl get nodes -o wide 2>/dev/null || echo "❌ Run 'make aks-creds' first to configure kubectl"

nginx-install: ## Install NGINX Ingress Controller
	@echo "🚀 Installing NGINX Ingress Controller..."
	@chmod +x scripts/install-nginx-ingress.sh
	@CLUSTER_NAME=$$(terraform output -raw aks_cluster_name 2>/dev/null || echo ""); \
	RG_NAME=$$(terraform output -raw resource_group_name 2>/dev/null || echo ""); \
	if [ -z "$$CLUSTER_NAME" ] || [ -z "$$RG_NAME" ]; then \
		echo "❌ AKS not deployed yet. Run 'make apply' first."; \
	else \
		./scripts/install-nginx-ingress.sh $$CLUSTER_NAME $$RG_NAME; \
	fi

nginx-status: ## Check NGINX Ingress Controller status
	@echo "📊 NGINX Ingress Controller Status:"
	@kubectl get pods -n ingress-nginx 2>/dev/null || echo "❌ NGINX Ingress not installed or kubectl not configured"
	@echo ""
	@kubectl get svc -n ingress-nginx 2>/dev/null || echo "❌ NGINX Ingress not installed or kubectl not configured"

k8s-dashboard: ## Install Kubernetes Dashboard
	@echo "📊 Installing Kubernetes Dashboard..."
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
	@echo "✅ Kubernetes Dashboard installed"
	@echo "💡 To access: kubectl proxy then visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

# Complete deployment workflow
deploy-all: apply aks-creds nginx-install ## Deploy everything (ACR + AKS + NGINX Ingress)
	@echo "🎉 Complete deployment finished!"
	@echo "📋 Summary:"
	@terraform output

dev-deploy-all: dev-apply aks-creds nginx-install ## Deploy everything for development
	@echo "🎉 Development deployment finished!"

prod-deploy-all: prod-apply aks-creds nginx-install ## Deploy everything for production
	@echo "🎉 Production deployment finished!"