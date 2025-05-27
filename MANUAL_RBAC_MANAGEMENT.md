# Manual RBAC Management Guide

## 🎯 Overview

You are now managing AKS RBAC permissions manually via the Azure Portal instead of Terraform. This gives you full control over who has access to your Kubernetes cluster.

## ✅ Changes Made

### **Removed from Terraform:**
- ❌ Azure AD provider configuration
- ❌ Service principal data source lookup
- ❌ Automatic RBAC role assignment
- ✅ Clean, simple infrastructure deployment

### **Manual Management Benefits:**
- ✅ **Full Control**: You decide exactly who gets access
- ✅ **Immediate Effect**: No waiting for Terraform propagation
- ✅ **Flexible**: Easy to add/remove users and service principals
- ✅ **Auditable**: Clear visibility in Azure Portal.

## 🔧 Current RBAC Setup

### **Service Principal Permissions:**
- **Service Principal**: Your GitHub Actions service principal
- **Role**: Azure Kubernetes Service RBAC Admin
- **Scope**: AKS cluster `aks-demo-cluster`
- **Assigned**: Manually via Azure Portal
- **Status**: ✅ Active

## 📋 Managing RBAC Permissions

### **Adding New Users/Service Principals:**

1. **Navigate to AKS Cluster:**
   - Azure Portal → Kubernetes services → `aks-demo-cluster`

2. **Access Control (IAM):**
   - Click **Access control (IAM)** in left menu
   - Click **+ Add** → **Add role assignment**

3. **Choose Role:**
   - **Azure Kubernetes Service RBAC Admin** - Full cluster admin
   - **Azure Kubernetes Service RBAC Cluster Admin** - Full cluster admin (broader)
   - **Azure Kubernetes Service RBAC Reader** - Read-only access
   - **Azure Kubernetes Service RBAC Writer** - Read/write access to most resources

4. **Select Member:**
   - Choose User, Group, or Service Principal
   - Search and select the identity
   - Click **Review + assign**

### **Removing Access:**

1. **Go to Access Control (IAM)**
2. **Click Role assignments tab**
3. **Find the user/service principal**
4. **Click the ... menu → Remove**

## 🔍 Current Role Assignments

You can view current assignments at:
**Azure Portal** → **Kubernetes services** → **aks-demo-cluster** → **Access control (IAM)** → **Role assignments**

**Current assignments:**
- ✅ Your GitHub Actions service principal: Azure Kubernetes Service RBAC Admin

## 🚀 Deployment Workflow

### **Your Current Setup:**
1. **Terraform** deploys AKS cluster (no RBAC management)
2. **Manual RBAC** assignments via Azure Portal
3. **GitHub Actions** uses service principal with manual permissions
4. **NGINX Ingress** installs successfully with proper permissions

### **GitHub Actions Workflow:**
```yaml
# Step 1: Deploy AKS Infrastructure (clean, no RBAC)
- name: Terraform Apply - AKS Infrastructure
  run: terraform apply -auto-approve -input=false

# Step 2: Install NGINX (uses manually assigned permissions)
- name: Install NGINX Ingress Controller
  run: |
    # Service principal already has manual RBAC permissions
    az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
    # ... install NGINX successfully
```

## 📚 Common RBAC Roles Explained

### **Azure Kubernetes Service RBAC Admin**
- **Permissions**: Full admin access to cluster
- **Can**: Create/delete namespaces, deploy applications, manage RBAC
- **Use for**: CI/CD service principals, cluster administrators

### **Azure Kubernetes Service RBAC Cluster Admin**
- **Permissions**: Full cluster admin (broader than RBAC Admin)
- **Can**: Everything, including cluster-level resources
- **Use for**: Super administrators

### **Azure Kubernetes Service RBAC Reader**
- **Permissions**: Read-only access
- **Can**: View resources, get logs, describe objects
- **Use for**: Monitoring, auditing, developers who need read access

### **Azure Kubernetes Service RBAC Writer**
- **Permissions**: Read/write access to most resources
- **Can**: Deploy applications, create services, but not manage RBAC
- **Use for**: Application developers

## 🔒 Security Best Practices

### **Principle of Least Privilege:**
- Give users/service principals only the minimum permissions needed
- Use **Reader** role for monitoring tools
- Use **Writer** role for application deployments
- Use **Admin** role only for infrastructure management

### **Regular Auditing:**
- Review role assignments monthly
- Remove unused service principals
- Check for overprivileged accounts

### **Service Principal Management:**
- Rotate service principal secrets regularly
- Use separate service principals for different environments
- Document what each service principal is used for

## 🎯 Next Steps

1. **✅ Your setup is complete** - RBAC is managed manually
2. **Re-run GitHub Actions** - Should now succeed completely
3. **Add more users** as needed using the steps above
4. **Monitor access** via Azure Portal IAM page

## 🆘 Troubleshooting

### **If GitHub Actions Still Fails:**
1. Verify service principal has the role in Azure Portal
2. Wait 2-3 minutes for propagation
3. Check the correct AKS cluster is selected
4. Try **Azure Kubernetes Service RBAC Cluster Admin** role instead

### **If Users Can't Access Cluster:**
1. Ensure they have appropriate Azure role on AKS cluster
2. They need to run: `az aks get-credentials --resource-group rg-acr-demo --name aks-demo-cluster`
3. If using Azure AD: `kubelogin convert-kubeconfig -l azurecli`

---

**RBAC Management**: ✅ Manual via Azure Portal  
**Terraform**: ✅ Clean infrastructure only  
**GitHub Actions**: ✅ Ready to deploy  
**Status**: ✅ Production Ready