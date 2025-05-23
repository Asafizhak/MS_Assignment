# Azure Container Registry and AKS Terraform Project Structure

## Overview
This is a modular Terraform project for deploying Azure Container Registry (ACR) and Azure Kubernetes Service (AKS) with NGINX Ingress Controller. The project includes GitHub Actions CI/CD pipeline and is optimized for cost-effectiveness with private network configuration.

## Project Structure

```
azure-acr-aks-terraform/
├── .gitignore                           # Git ignore file for Terraform
├── main.tf                              # Main Terraform configuration
├── variables.tf                         # Input variables definition
├── outputs.tf                           # Output values
├── versions.tf                          # Terraform and provider version constraints
├── terraform.tfvars.example             # Example variables file
├── Makefile                             # Common operations automation
├── README.md                            # Comprehensive documentation
├── PROJECT_STRUCTURE.md                 # This file
├── AKS_DEPLOYMENT_GUIDE.md              # AKS deployment guide
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
│   ├── acr/                            # Azure Container Registry module
│   │   ├── main.tf                     # ACR resource configuration
│   │   ├── variables.tf                # Module input variables
│   │   └── outputs.tf                  # Module outputs
│   └── aks/                            # Azure Kubernetes Service module
│       ├── main.tf                     # AKS resource configuration
│       ├── variables.tf                # Module input variables
│       └── outputs.tf                  # Module outputs
│
└── scripts/
    ├── setup.sh                        # Interactive setup script
    └── install-nginx-ingress.sh        # NGINX Ingress installation script
```

## Key Features

### 🏗️ Modular Architecture
- **Reusable ACR Module**: Self-contained module for Azure Container Registry
- **Reusable AKS Module**: Self-contained module for Azure Kubernetes Service
- **Environment Separation**: Separate variable files for dev/prod environments
- **Scalable Design**: Modular design allows easy extension with additional services

### 💰 Cost Optimized
- **Basic SKU**: Cheapest ACR option (~$5/month)
- **Free AKS Tier**: No control plane costs for development
- **Standard_B2s VMs**: Cost-effective node sizes for demo purposes
- **Ephemeral OS Disks**: Reduced storage costs
- **West Europe Region**: Cost-effective Azure region

### 🔒 Security Focused
- **Private AKS Cluster**: API server not exposed to internet
- **Internal Load Balancer**: NGINX Ingress with internal Azure LB
- **Network Policies**: Azure CNI with network policy enforcement
- **RBAC Enabled**: Role-based access control with Azure AD
- **ACR Integration**: Secure container image pulling

### 🚀 CI/CD Ready
- **GitHub Actions**: Automated deployment pipeline
- **Service Principal Auth**: Secure authentication using GitHub secrets
- **Branch Protection**: Different behaviors for main/develop branches
- **Validation Pipeline**: Format, validate, and plan on PRs

### 🛠️ Developer Experience
- **Makefile**: Common commands automation including AKS management
- **Setup Scripts**: Interactive project configuration and NGINX installation
- **Multiple Environments**: Easy switching between dev/prod
- **Comprehensive Documentation**: Detailed guides and examples

## Resource Configuration

### Azure Container Registry
- **SKU**: Basic (cheapest option)
- **Admin User**: Enabled for easy authentication
- **Public Access**: Enabled (can be restricted later)
- **Location**: West Europe (cost-effective)

### Azure Kubernetes Service
- **SKU Tier**: Free (dev) / Standard (prod)
- **Node Pool**: 1-2 nodes with Standard_B2s VMs
- **Network**: Private cluster with custom VNet
- **Ingress**: NGINX with internal load balancer
- **Identity**: System-assigned managed identity

### Virtual Network
- **Address Space**: 10.0.0.0/16
- **AKS Nodes Subnet**: 10.0.1.0/24
- **App Gateway Subnet**: 10.0.2.0/24 (reserved)
- **Service CIDR**: 10.1.0.0/16

### Resource Group
- **Naming**: Environment-specific (rg-acr-aks-demo-{env})
- **Tags**: Comprehensive tagging strategy
- **Location**: Consistent across all resources

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

This project can be extended with:

- **Key Vault Module**: Secure secret management
- **Azure Monitor Module**: Comprehensive monitoring and alerting
- **Backup Module**: Container image and cluster backup strategy
- **Application Gateway Module**: Advanced ingress with WAF
- **Azure Policy Module**: Governance and compliance

## Cost Estimation

### Development Environment
- **ACR Basic**: ~$5 USD/month
- **AKS Control Plane**: Free
- **1x Standard_B2s Node**: ~$30 USD/month
- **Load Balancer**: ~$20 USD/month
- **Total**: ~$55 USD/month

### Production Environment
- **ACR Basic**: ~$5 USD/month
- **AKS Control Plane**: ~$75 USD/month
- **2x Standard_B2s Nodes**: ~$60 USD/month
- **Load Balancer**: ~$20 USD/month
- **Total**: ~$160 USD/month

## Support

For issues and questions:
1. Check the README.md for detailed documentation
2. Review the Makefile for available commands
3. Use the setup script for initial configuration
4. Refer to Azure documentation for ACR specifics

## License

This project is provided as-is for demonstration purposes.