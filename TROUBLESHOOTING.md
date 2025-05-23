# Troubleshooting Guide - Azure AKS + ACR Terraform Deployment

## Common Issues and Solutions

### 1. Role Assignment Authorization Error

**Error:**
```
Error: authorization.RoleAssignmentsClient#Create: Failure responding to request: StatusCode=403
Code="AuthorizationFailed" Message="The client does not have authorization to perform action 
'Microsoft.Authorization/roleAssignments/write'"
```

**Solution:**
This error occurs when the service principal doesn't have sufficient permissions to create role assignments.

**Option A: Grant Additional Permissions (Recommended for Production)**
```bash
# Grant User Access Administrator role to the service principal
az role assignment create \
  --assignee <SERVICE_PRINCIPAL_ID> \
  --role "User Access Administrator" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>"
```

**Option B: Manual Role Assignment (Recommended for Demo)**
1. Deploy without automatic role assignment (default configuration)
2. Run the manual setup script after deployment:
```bash
make acr-integration
```

**Option C: Enable Automatic Role Assignment**
Set `aks_enable_acr_role_assignment = true` in your `.tfvars` file if you have the required permissions.

### 2. Azure AD Integration Deprecation Warning

**Warning:**
```
Warning: Argument is deprecated
Azure AD Integration (legacy) is deprecated
```

**Solution:**
This is just a warning and doesn't affect functionality. The configuration uses the current recommended approach for Azure AD integration with AKS.

### 3. Terraform Count/For_Each Argument Error

**Error:**
```
Error: Invalid count argument / Invalid for_each argument

The "count"/"for_each" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be
created.
```

**Solution:**
This error occurs when using `count` or `for_each` with values that depend on resource outputs. The issue has been resolved by using a map-based `for_each` with static keys in the role assignment resource:

```hcl
# Fixed implementation:
resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = var.enable_acr_role_assignment ? { "acr_pull" = var.acr_id } : {}
  
  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
```

1. **Update to latest code** - The fix is already implemented
2. **Alternative workaround** - Use targeted apply:
```bash
terraform apply -target=module.acr
terraform apply
```

### 4. AKS Cluster Creation Timeout

**Error:**
```
Error: timeout while waiting for state to become 'Succeeded'
```

**Solutions:**
- Increase timeout in provider configuration
- Check Azure region capacity
- Verify subscription quotas for VM cores
- Try a different VM size (Standard_B2s is usually available)

### 4. Network Configuration Issues

**Error:**
```
Error: subnet address space conflicts
```

**Solution:**
Ensure the network address spaces don't conflict:
- VNet: `10.0.0.0/16`
- AKS Nodes: `10.0.1.0/24`
- Service CIDR: `10.1.0.0/16`
- DNS Service IP: `10.1.0.10`

### 5. NGINX Ingress Installation Fails

**Error:**
```
Error: failed to install nginx-ingress
```

**Solutions:**
1. Ensure AKS cluster is running:
```bash
kubectl get nodes
```

2. Check cluster credentials:
```bash
make aks-creds
```

3. Manually install NGINX Ingress:
```bash
make nginx-install
```

4. Check Helm repository access:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

### 6. kubectl Connection Issues

**Error:**
```
Error: Unable to connect to the server
```

**Solutions:**
1. Get fresh credentials:
```bash
make aks-creds
```

2. Verify cluster is running:
```bash
az aks show --resource-group <RG_NAME> --name <CLUSTER_NAME> --query "powerState"
```

3. Check private cluster access (if using private cluster):
   - Ensure you're connecting from within the VNet or via VPN/ExpressRoute
   - For testing, you can use Azure Cloud Shell

### 7. Container Image Pull Issues

**Error:**
```
Error: ErrImagePull or ImagePullBackOff
```

**Solutions:**
1. Verify ACR integration:
```bash
make acr-integration
```

2. Check role assignments:
```bash
az role assignment list --scope $(terraform output -raw acr_id)
```

3. Test ACR access from AKS:
```bash
kubectl run test --image=$(terraform output -raw acr_login_server)/hello-world:latest --rm -it
```

### 8. Terraform State Lock Issues

**Error:**
```
Error: Error acquiring the state lock
```

**Solutions:**
1. Wait for other operations to complete
2. Force unlock (use with caution):
```bash
terraform force-unlock <LOCK_ID>
```

### 9. Resource Quota Exceeded

**Error:**
```
Error: Operation could not be completed as it results in exceeding approved quota
```

**Solutions:**
1. Check current quotas:
```bash
az vm list-usage --location "West Europe" --output table
```

2. Request quota increase through Azure portal
3. Use smaller VM sizes or reduce node count
4. Try different Azure regions

### 10. Private Cluster Access Issues

**Issue:** Cannot access private AKS cluster API

**Solutions:**
1. **From Azure Cloud Shell:**
```bash
az cloud-shell
make aks-creds
kubectl get nodes
```

2. **From Jump Box/Bastion:**
   - Deploy a VM in the same VNet
   - Install kubectl and Azure CLI
   - Get cluster credentials

3. **VPN/ExpressRoute:**
   - Configure site-to-site VPN
   - Set up ExpressRoute connection

## Deployment Verification Checklist

### ✅ Pre-Deployment
- [ ] Azure CLI installed and authenticated
- [ ] Terraform >= 1.5.0 installed
- [ ] kubectl installed
- [ ] Helm installed
- [ ] Sufficient Azure permissions

### ✅ Post-Deployment
- [ ] Terraform apply completed successfully
- [ ] AKS cluster is running: `make aks-info`
- [ ] kubectl configured: `make aks-creds`
- [ ] Nodes are ready: `make aks-nodes`
- [ ] NGINX Ingress installed: `make nginx-install`
- [ ] ACR integration working: `make acr-integration`

## Useful Commands

### Terraform
```bash
terraform validate          # Validate configuration
terraform plan             # Preview changes
terraform apply            # Apply changes
terraform destroy          # Destroy resources
```

### AKS Management
```bash
make aks-creds             # Get cluster credentials
make aks-info              # Show cluster info
make aks-nodes             # List cluster nodes
make nginx-install         # Install NGINX Ingress
make nginx-status          # Check NGINX status
make acr-integration       # Setup ACR integration
```

### Kubernetes Debugging
```bash
kubectl get nodes -o wide                    # Check node status
kubectl get pods --all-namespaces          # List all pods
kubectl describe pod <POD_NAME>             # Pod details
kubectl logs <POD_NAME>                     # Pod logs
kubectl get events --sort-by=.metadata.creationTimestamp  # Recent events
```

### ACR Debugging
```bash
az acr list                                 # List registries
az acr login --name <ACR_NAME>             # Login to ACR
az acr repository list --name <ACR_NAME>   # List repositories
```

## Getting Help

1. **Check Azure Status:** https://status.azure.com/
2. **Azure Documentation:** https://docs.microsoft.com/azure/
3. **Terraform AzureRM Provider:** https://registry.terraform.io/providers/hashicorp/azurerm/
4. **Kubernetes Documentation:** https://kubernetes.io/docs/

## Support Contacts

For project-specific issues:
1. Review this troubleshooting guide
2. Check the deployment logs
3. Verify Azure resource status in the portal
4. Test with minimal configuration first

---

**Last Updated:** $(date)
**Terraform Version:** >= 1.5.0
**Azure Provider Version:** ~> 3.0