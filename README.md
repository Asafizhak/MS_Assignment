# Azure Container Registry (ACR) Terraform Project

This project provides a modular Terraform configuration for deploying Azure Container Registry (ACR) with GitHub Actions CI/CD pipeline.

## Project Structure

```
.
├── main.tf                           # Main Terraform configuration
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── terraform.tfvars.example          # Example variables file
├── modules/
│   └── acr/                         # ACR module
│       ├── main.tf                  # ACR resource configuration
│       ├── variables.tf             # Module input variables
│       └── outputs.tf               # Module outputs
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml     # GitHub Actions workflow
└── README.md                        # This file
```

## Prerequisites

1. **Azure Subscription**: Active Azure subscription
2. **Azure CLI**: Installed and configured
3. **Terraform**: Version 1.5.0 or later
4. **GitHub Repository**: For CI/CD pipeline
5. **Service Principal**: For GitHub Actions authentication

## Setup Instructions

### 1. Create Azure Service Principal

Create a Service Principal for GitHub Actions to authenticate with Azure:

```bash
# Login to Azure
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Create Service Principal
az ad sp create-for-rbac --name "GitHub-Actions-SPN" \
  --role contributor \
  --scopes /subscriptions/your-subscription-id \
  --sdk-auth
```

Save the output JSON - you'll need it for GitHub secrets.

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AZURE_CLIENT_ID`: Application (client) ID
- `AZURE_CLIENT_SECRET`: Client secret value
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_TENANT_ID`: Directory (tenant) ID

### 3. Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your specific values:
   ```hcl
   resource_group_name = "rg-acr-demo-prod"
   location           = "West Europe"
   acr_name          = "acrdemoprod123"  # Must be globally unique
   acr_sku           = "Basic"           # Cheapest option
   environment       = "prod"
   ```

### 3. Configure Remote State Backend

This project uses Azure Blob Storage for remote state management. The backend configuration is in [`backend-config.hcl`](backend-config.hcl):

- **Storage Account**: `msassignmenttfstate1`
- **Resource Group**: `Storage_SG`
- **Container**: `tfstate`
- **State File**: `acr-demo.terraform.tfstate`

For detailed information about the remote state setup, see [`BACKEND_SETUP.md`](BACKEND_SETUP.md).

### 4. Local Development Setup

For local testing and development:

```bash
# Initialize Terraform with remote state
terraform init \
  -backend-config="resource_group_name=Storage_SG" \
  -backend-config="storage_account_name=msassignmenttfstate1" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=acr-demo.terraform.tfstate"

# Validate configuration
terraform validate

# Format code
terraform fmt

# Plan deployment
terraform plan

# Apply changes (if needed)
terraform apply
```

## ACR Configuration

### SKU Options (Cheapest to Most Expensive)

1. **Basic** (Recommended for demo): 
   - Lowest cost
   - 10 GB storage included
   - No geo-replication
   - No advanced features

2. **Standard**: 
   - 100 GB storage included
   - Webhook support

3. **Premium**: 
   - 500 GB storage included
   - Geo-replication
   - Private endpoints
   - Advanced security features

### Default Configuration

- **SKU**: Basic (cheapest option)
- **Admin User**: Enabled (for easy authentication)
- **Public Access**: Enabled
- **Location**: West Europe

## GitHub Actions Workflow

The workflow automatically:

1. **On Pull Request**: 
   - Validates Terraform code
   - Runs `terraform plan`

2. **On Push to Main**: 
   - Validates and plans
   - Applies changes to Azure
   - Outputs deployment results

### Workflow Triggers

- Push to `main` branch (deploys to production)
- Push to `develop` branch (validates only)
- Pull requests to `main` branch (validates only)

## Usage Examples

### Accessing Your ACR

After deployment, you can:

```bash
# Login to ACR (using admin credentials)
az acr login --name your-acr-name

# Or using Docker directly
docker login your-acr-name.azurecr.io

# Tag and push an image
docker tag my-app:latest your-acr-name.azurecr.io/my-app:latest
docker push your-acr-name.azurecr.io/my-app:latest
```

### Getting ACR Credentials

```bash
# Get admin credentials
az acr credential show --name your-acr-name --resource-group your-rg-name
```

## Outputs

The Terraform configuration provides these outputs:

- `acr_name`: Name of the created ACR
- `acr_login_server`: Login server URL
- `acr_id`: Resource ID
- `acr_admin_username`: Admin username (sensitive)
- `acr_admin_password`: Admin password (sensitive)

## Cost Optimization

This configuration is optimized for minimal cost:

- Uses **Basic SKU** (cheapest option)
- Deploys to **East US** (cost-effective region)
- No premium features enabled
- No geo-replication

**Estimated Monthly Cost**: ~$5 USD for Basic SKU

## Security Considerations

For production environments, consider:

1. **Disable Admin User**: Use Azure AD authentication instead
2. **Private Endpoints**: Restrict network access (Premium SKU required)
3. **RBAC**: Implement proper role-based access control
4. **Image Scanning**: Enable vulnerability scanning (Standard/Premium)

## Future Enhancements

This project is designed to be extended with:

- **AKS Module**: Kubernetes cluster integration
- **Key Vault**: Secure secret management
- **Virtual Network**: Network isolation
- **Monitoring**: Azure Monitor integration

## Troubleshooting

### Common Issues

1. **ACR Name Not Available**: ACR names must be globally unique
2. **Permission Denied**: Ensure Service Principal has Contributor role
3. **Terraform State**: Consider using remote state storage for team collaboration

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resources
terraform import azurerm_resource_group.main /subscriptions/sub-id/resourceGroups/rg-name

# Destroy resources (be careful!)
terraform destroy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request

## License

This project is licensed under the MIT License..