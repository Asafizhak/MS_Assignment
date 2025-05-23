# Azure Container Registry Terraform Makefile
# Provides common commands for managing the Terraform infrastructure

.PHONY: help init plan apply destroy validate format clean setup

# Default target
help: ## Show this help message
	@echo "Azure Container Registry Terraform Commands"
	@echo "=========================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Run the setup script to configure the project
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

init: ## Initialize Terraform
	@echo "🏗️  Initializing Terraform..."
	@terraform init -backend-config=backend-config.hcl

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