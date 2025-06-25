# Terraform Remote State Configuration

This document explains how the Terraform state is configured to use Azure Blob Storage for remote state management.

## Backend Configuration

### Current Setup
- **Storage Account**: `msassignmenttfstate1`
- **Resource Group**: `Storage_SG`
- **Container**: `tfstate`
- **State File**: `acr-demo.terraform.tfstate`
- **Location**: West Europe

### Backend Configuration
The backend configuration uses individual command-line parameters:

```bash
terraform init \
  -backend-config="resource_group_name=Storage_SG" \
  -backend-config="storage_account_name=msassignmenttfstate1" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=acr-demo.terraform.tfstate"
```

## How It Works

### GitHub Actions
The GitHub Actions workflow automatically uses the remote state:
```yaml
- name: Terraform Init
  run: |
    terraform init \
      -backend-config="resource_group_name=Storage_SG" \
      -backend-config="storage_account_name=msassignmenttfstate1" \
      -backend-config="container_name=tfstate" \
      -backend-config="key=acr-demo.terraform.tfstate"
```

### Local Development
For local development, use the Makefile or direct commands:
```bash
# Using Makefile
make init

# Direct Terraform command
terraform init \
  -backend-config="resource_group_name=Storage_SG" \
  -backend-config="storage_account_name=msassignmenttfstate1" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=acr-demo.terraform.tfstate"
```

## Benefits of Remote State

### 1. **Team Collaboration**
- Multiple developers can work on the same infrastructure
- State is centrally stored and accessible to authorized users
- Prevents conflicts from local state files

### 2. **State Locking**
- Azure Blob Storage provides automatic state locking
- Prevents concurrent modifications
- Ensures state consistency

### 3. **Security**
- State file is stored securely in Azure
- Access controlled via Azure RBAC
- Encrypted at rest and in transit

### 4. **Backup and Recovery**
- Azure Blob Storage provides built-in redundancy
- State file is automatically backed up
- Easy to restore if needed

## Prerequisites

### Azure Storage Account Setup
Your storage account should have:
1. **Blob Storage enabled**
2. **Container named `tfstate`**
3. **Proper access permissions for the Service Principal**

### Required Permissions
The Service Principal needs these permissions on the storage account:
- `Storage Blob Data Contributor` role
- Or custom role with these permissions:
  - `Microsoft.Storage/storageAccounts/blobServices/containers/read`
  - `Microsoft.Storage/storageAccounts/blobServices/containers/write`
  - `Microsoft.Storage/storageAccounts/blobServices/generateUserDelegationKey/action`

## Troubleshooting

### Common Issues

#### 1. **Access Denied Error**
```
Error: Failed to get existing workspaces: storage: service returned error: StatusCode=403
```
**Solution**: Ensure the Service Principal has proper permissions on the storage account.

#### 2. **Container Not Found**
```
Error: container "tfstate" was not found
```
**Solution**: Create the container in your storage account or update the container name in `backend-config.hcl`.

#### 3. **Storage Account Not Found**
```
Error: storage account "msassignmenttfstate1" was not found
```
**Solution**: Verify the storage account name and ensure it exists in the specified resource group.

### Verification Commands

Check if your storage account is accessible:
```bash
# List storage accounts
az storage account list --resource-group Storage_SG

# Check container exists
az storage container list --account-name msassignmenttfstate1

# Verify permissions
az role assignment list --assignee <service-principal-id> --scope /subscriptions/<subscription-id>/resourceGroups/Storage_SG/providers/Microsoft.Storage/storageAccounts/msassignmenttfstate1
```

## State Migration

### From Local to Remote State
If you have existing local state, migrate it:

```bash
# 1. Backup existing state
cp terraform.tfstate terraform.tfstate.backup

# 2. Initialize with backend config
terraform init -backend-config=backend-config.hcl

# 3. Terraform will prompt to migrate state - answer 'yes'
```

### Between Different Remote Backends
To change backend configuration:

```bash
# 1. Update backend-config.hcl with new values
# 2. Re-initialize
terraform init -backend-config=backend-config.hcl -migrate-state
```

## Security Best Practices

### 1. **Access Control**
- Use Azure RBAC for fine-grained access control
- Limit access to the storage account
- Use managed identities where possible

### 2. **Network Security**
- Consider using private endpoints for the storage account
- Restrict network access if needed
- Enable storage account firewall rules

### 3. **Monitoring**
- Enable storage account logging
- Monitor access to the state file
- Set up alerts for unauthorized access

### 4. **Encryption**
- State file is encrypted at rest by default
- Consider using customer-managed keys for additional security
- Ensure TLS encryption for data in transit

## Environment-Specific State

For multiple environments, consider using different state files:

```hcl
# Development
key = "environments/dev/terraform.tfstate"

# Production  
key = "environments/prod/terraform.tfstate"
```

Or use separate storage accounts per environment for better isolation.

## Backup Strategy

### Automatic Backups
Azure Blob Storage provides:
- **Geo-redundant storage (GRS)** for cross-region backup
- **Point-in-time restore** capabilities
- **Soft delete** for accidental deletion protection

### Manual Backups
For critical deployments:
```bash
# Download current state
az storage blob download \
  --account-name msassignmenttfstate1 \
  --container-name tfstate \
  --name acr-demo.terraform.tfstate \
  --file backup-$(date +%Y%m%d).tfstate
```

## Monitoring and Alerts

Set up monitoring for:
- State file access and modifications
- Failed state operations
- Storage account health
- Unusual access patterns

Example Azure Monitor alert for state file changes:
```json
{
  "condition": {
    "allOf": [
      {
        "field": "category",
        "equals": "StorageWrite"
      },
      {
        "field": "resourceId",
        "contains": "tfstate"
      }
    ]
  }
}
```

This ensures you're notified of any changes to your Terraform state files.