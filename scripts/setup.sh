#!/bin/bash

# Azure Container Registry Terraform Setup Script
# This script helps set up the initial configuration for the ACR Terraform project

set -e

echo "🚀 Azure Container Registry Terraform Setup"
echo "=========================================="

# Check if required tools are installed
check_requirements() {
    echo "📋 Checking requirements..."
    
    if ! command -v az &> /dev/null; then
        echo "❌ Azure CLI is not installed. Please install it first."
        echo "   Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        echo "❌ Terraform is not installed. Please install it first."
        echo "   Visit: https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    echo "✅ All requirements met!"
}

# Login to Azure
azure_login() {
    echo "🔐 Azure Authentication..."
    
    if ! az account show &> /dev/null; then
        echo "Please login to Azure:"
        az login
    else
        echo "✅ Already logged in to Azure"
        az account show --query "{subscriptionId:id, subscriptionName:name, user:user.name}" -o table
    fi
}

# Create Service Principal
create_service_principal() {
    echo "🔑 Creating Service Principal for GitHub Actions..."
    
    read -p "Enter your Azure Subscription ID: " SUBSCRIPTION_ID
    
    if [[ -z "$SUBSCRIPTION_ID" ]]; then
        echo "❌ Subscription ID is required"
        exit 1
    fi
    
    # Set the subscription
    az account set --subscription "$SUBSCRIPTION_ID"
    
    # Create Service Principal
    echo "Creating Service Principal 'GitHub-Actions-SPN'..."
    SP_OUTPUT=$(az ad sp create-for-rbac --name "GitHub-Actions-SPN-$(date +%s)" \
        --role contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID" \
        --sdk-auth)
    
    echo "✅ Service Principal created successfully!"
    echo ""
    echo "🔐 GitHub Secrets Configuration"
    echo "Add these secrets to your GitHub repository:"
    echo "Settings → Secrets and variables → Actions → New repository secret"
    echo ""
    
    # Parse the JSON output
    CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
    CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')
    TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenantId')
    
    echo "AZURE_CLIENT_ID: $CLIENT_ID"
    echo "AZURE_CLIENT_SECRET: $CLIENT_SECRET"
    echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
    echo "AZURE_TENANT_ID: $TENANT_ID"
    echo ""
    echo "⚠️  Save these values securely - they won't be shown again!"
}

# Setup terraform.tfvars
setup_tfvars() {
    echo "📝 Setting up terraform.tfvars..."
    
    if [[ -f "terraform.tfvars" ]]; then
        echo "⚠️  terraform.tfvars already exists. Skipping..."
        return
    fi
    
    cp terraform.tfvars.example terraform.tfvars
    
    echo "✅ Created terraform.tfvars from example"
    echo "📝 Please edit terraform.tfvars with your specific values:"
    echo "   - Update acr_name to be globally unique"
    echo "   - Adjust location if needed"
    echo "   - Modify tags as appropriate"
}

# Initialize Terraform
init_terraform() {
    echo "🏗️  Initializing Terraform..."
    
    terraform init \
        -backend-config="resource_group_name=Storage_SG" \
        -backend-config="storage_account_name=msassignmenttfstate1" \
        -backend-config="container_name=tfstate" \
        -backend-config="key=acr-demo.terraform.tfstate"
    terraform validate
    terraform fmt
    
    echo "✅ Terraform initialized and validated successfully!"
}

# Main execution
main() {
    check_requirements
    azure_login
    
    echo ""
    read -p "Do you want to create a Service Principal for GitHub Actions? (y/n): " CREATE_SP
    if [[ "$CREATE_SP" =~ ^[Yy]$ ]]; then
        create_service_principal
    fi
    
    echo ""
    setup_tfvars
    
    echo ""
    read -p "Do you want to initialize Terraform? (y/n): " INIT_TF
    if [[ "$INIT_TF" =~ ^[Yy]$ ]]; then
        init_terraform
    fi
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Edit terraform.tfvars with your values"
    echo "2. Add GitHub secrets (if you created a Service Principal)"
    echo "3. Run 'terraform plan' to review changes"
    echo "4. Run 'terraform apply' to deploy resources"
    echo ""
    echo "For more information, see README.md"
}

# Run main function
main "$@"