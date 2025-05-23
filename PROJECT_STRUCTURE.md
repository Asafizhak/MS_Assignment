# Azure Container Registry Terraform Project Structure

## Overview
This is a modular Terraform project for deploying Azure Container Registry (ACR) with GitHub Actions CI/CD pipeline, optimized for cost-effectiveness using the Basic SKU.

## Project Structure

```
azure-acr-terraform/
├── .gitignore                           # Git ignore file for Terraform
├── main.tf                              # Main Terraform configuration
├── variables.tf                         # Input variables definition
├── outputs.tf                           # Output values
├── versions.tf                          # Terraform and provider version constraints
├── terraform.tfvars.example             # Example variables file
├── Makefile                             # Common operations automation
├── README.md                            # Comprehensive documentation
├── PROJECT_STRUCTURE.md                 # This file
│
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml         # GitHub Actions CI/CD pipeline
│
├── environments/
│   ├── dev.tfvars                       # Development environment variables
│   └── prod.tfvars                      # Production environment variables
│
├── modules/
│   └── acr/                            # Azure Container Registry module
│       ├── main.tf                     # ACR resource configuration
│       ├── variables.tf                # Module input variables
│       └── outputs.tf                  # Module outputs
│
└── scripts/
    └── setup.sh                        # Interactive setup script
```

## Key Features

### 🏗️ Modular Architecture
- **Reusable ACR Module**: Self-contained module for Azure Container Registry
- **Environment Separation**: Separate variable files for dev/prod environments
- **Scalable Design**: Easy to extend with additional Azure services (AKS, Key Vault, etc.)

### 💰 Cost Optimized
- **Basic SKU**: Cheapest ACR option (~$5/month)
- **East US Region**: Cost-effective Azure region
- **Minimal Features**: Only essential features enabled for demo purposes

### 🚀 CI/CD Ready
- **GitHub Actions**: Automated deployment pipeline
- **Service Principal Auth**: Secure authentication using GitHub secrets
- **Branch Protection**: Different behaviors for main/develop branches
- **Validation Pipeline**: Format, validate, and plan on PRs

### 🛠️ Developer Experience
- **Makefile**: Common commands automation
- **Setup Script**: Interactive project configuration
- **Multiple Environments**: Easy switching between dev/prod
- **Comprehensive Documentation**: Detailed README with examples

## Resource Configuration

### Azure Container Registry
- **SKU**: Basic (cheapest option)
- **Admin User**: Enabled for easy authentication
- **Public Access**: Enabled (can be restricted later)
- **Location**: East US (cost-effective)

### Resource Group
- **Naming**: Environment-specific (rg-acr-demo-{env})
- **Tags**: Comprehensive tagging strategy
- **Location**: Consistent with ACR location

## Security Considerations

### Current Setup (Demo-Friendly)
- Admin user enabled for easy access
- Public network access allowed
- Basic authentication supported

### Production Recommendations
- Disable admin user, use Azure AD
- Implement private endpoints (Premium SKU)
- Enable vulnerability scanning
- Use managed identities where possible

## Deployment Options

### 1. GitHub Actions (Recommended)
```bash
# Push to main branch triggers deployment
git push origin main
```

### 2. Local Development
```bash
# Using Makefile
make setup
make plan
make apply

# Using Terraform directly
terraform init
terraform plan
terraform apply
```

### 3. Environment-Specific
```bash
# Development
make dev-plan
make dev-apply

# Production
make prod-plan
make prod-apply
```

## Required GitHub Secrets

Set these in your GitHub repository settings:

| Secret Name | Description |
|-------------|-------------|
| `AZURE_CLIENT_ID` | Service Principal Application ID |
| `AZURE_CLIENT_SECRET` | Service Principal Secret |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `AZURE_TENANT_ID` | Azure Tenant ID |

## Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository-url>
   cd azure-acr-terraform
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

2. **Configure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Deploy**
   ```bash
   make plan
   make apply
   ```

## Future Enhancements

This project is designed to be extended with:

- **AKS Module**: Kubernetes cluster integration
- **Key Vault Module**: Secure secret management
- **Virtual Network Module**: Network isolation
- **Monitoring Module**: Azure Monitor integration
- **Backup Module**: Container image backup strategy

## Cost Estimation

**Monthly Costs (Basic SKU)**:
- ACR Basic: ~$5 USD
- Resource Group: Free
- **Total**: ~$5 USD/month

## Support

For issues and questions:
1. Check the README.md for detailed documentation
2. Review the Makefile for available commands
3. Use the setup script for initial configuration
4. Refer to Azure documentation for ACR specifics

## License

This project is provided as-is for demonstration purposes.