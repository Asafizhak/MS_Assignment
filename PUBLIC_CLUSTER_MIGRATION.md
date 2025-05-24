# Migration from Private to Public AKS Cluster

## 🔄 Overview

This document describes the changes made to convert your AKS cluster from private to public configuration to resolve connectivity issues while maintaining security best practices.

## 📋 Changes Made

### 1. **AKS Cluster Configuration**
**File**: [`modules/aks/main.tf`](modules/aks/main.tf)

```hcl
# BEFORE (Private Cluster)
private_cluster_enabled             = true
private_dns_zone_id                 = "System"
private_cluster_public_fqdn_enabled = false

# AFTER (Public Cluster with Security)
private_cluster_enabled         = false
api_server_authorized_ip_ranges = var.authorized_ip_ranges
```

### 2. **New Security Variables**
**Files**: [`modules/aks/variables.tf`](modules/aks/variables.tf), [`variables.tf`](variables.tf)

Added `authorized_ip_ranges` variable to restrict API server access to specific IP addresses:

```hcl
variable "authorized_ip_ranges" {
  description = "List of authorized IP ranges that can access the Kubernetes API server"
  type        = list(string)
  default     = null
  
  validation {
    condition = var.authorized_ip_ranges == null || alltrue([
      for ip in var.authorized_ip_ranges : can(cidrhost(ip, 0))
    ])
    error_message = "All IP ranges must be valid CIDR blocks."
  }
}
```

### 3. **Module Integration**
**File**: [`main.tf`](main.tf)

```hcl
module "aks" {
  # ... existing configuration ...
  authorized_ip_ranges = var.aks_authorized_ip_ranges
  # ... rest of configuration ...
}
```

### 4. **IP Detection Scripts**
Created helper scripts to get your public IP address:

- **Linux/Mac**: [`scripts/get-my-ip.sh`](scripts/get-my-ip.sh)
- **Windows**: [`scripts/get-my-ip.bat`](scripts/get-my-ip.bat)

### 5. **Configuration Examples**
**File**: [`terraform.tfvars.example`](terraform.tfvars.example)

```hcl
# Authorized IP ranges for AKS API server access (for public clusters)
# Leave commented for unrestricted access, or specify your IP ranges for security
# Get your IP using: scripts/get-my-ip.sh (Linux/Mac) or scripts/get-my-ip.bat (Windows)
# aks_authorized_ip_ranges = ["YOUR_IP/32"]
# Example with multiple IPs:
# aks_authorized_ip_ranges = ["203.0.113.5/32", "198.51.100.0/24", "192.0.2.10/32"]
```

### 6. **Enhanced Makefile**
**File**: [`Makefile`](Makefile)

Added new commands:
- `make get-my-ip` - Get your public IP address
- `make test-connection` - Test AKS cluster connectivity

## 🔒 Security Considerations

### **Before (Private Cluster)**
- ✅ API server completely private
- ❌ Difficult to access without VPN/Jump box
- ❌ Complex setup for CI/CD pipelines
- ❌ Limited accessibility for development

### **After (Public Cluster with IP Restrictions)**
- ✅ Easy access from authorized IPs
- ✅ Simple CI/CD integration
- ✅ Better development experience
- ✅ Configurable security with IP restrictions
- ⚠️ Requires proper IP range configuration

## 🚀 Deployment Steps

### **Step 1: Get Your Public IP**
```bash
# Linux/Mac
./scripts/get-my-ip.sh

# Windows
scripts\get-my-ip.bat

# Or use Makefile
make get-my-ip
```

### **Step 2: Configure IP Restrictions (Recommended)**
Create or update your `terraform.tfvars` file:

```hcl
# Add your IP address for security
aks_authorized_ip_ranges = ["YOUR_IP/32"]

# For multiple locations (office, home, etc.)
aks_authorized_ip_ranges = [
  "203.0.113.5/32",      # Your home IP
  "198.51.100.0/24",     # Office network
  "192.0.2.10/32"        # VPN IP
]
```

### **Step 3: Deploy the Changes**
```bash
# Plan the changes
terraform plan

# Apply the changes
terraform apply

# Or use Makefile
make apply
```

### **Step 4: Test Connectivity**
```bash
# Test cluster access
make test-connection

# Or manually
az aks get-credentials --resource-group rg-acr-demo --name aks-demo-cluster
kubectl get nodes
```

## ⚠️ Important Security Notes

### **Unrestricted Access (Not Recommended)**
If you don't set `aks_authorized_ip_ranges`, the cluster API will be accessible from **any IP address** on the internet. This is convenient but less secure.

### **Recommended Security Setup**
Always configure authorized IP ranges:

```hcl
# Minimal security - your current IP only
aks_authorized_ip_ranges = ["YOUR_IP/32"]

# Better security - specific known ranges
aks_authorized_ip_ranges = [
  "203.0.113.5/32",      # Your specific IP
  "198.51.100.0/24",     # Your office network
  "0.0.0.0/0"            # Remove this - allows all IPs
]
```

### **Dynamic IP Considerations**
If your IP address changes frequently:
1. Use your ISP's IP range instead of `/32`
2. Include multiple common locations
3. Update the ranges when needed
4. Consider using Azure Bastion for consistent access

## 🔧 Troubleshooting

### **Connection Refused Errors**
```bash
# Check if your IP is authorized
kubectl cluster-info

# If blocked, update your IP ranges
# Get current IP
make get-my-ip

# Update terraform.tfvars with new IP
# Apply changes
terraform apply
```

### **Access from CI/CD**
For GitHub Actions or other CI/CD systems:
```hcl
# Add GitHub Actions IP ranges (if using GitHub-hosted runners)
aks_authorized_ip_ranges = [
  "YOUR_IP/32",
  "20.201.28.151/32",    # GitHub Actions (example)
  "20.205.243.166/32"    # GitHub Actions (example)
]
```

### **Emergency Access**
If you're locked out:
1. Use Azure Cloud Shell (always has access)
2. Update IP ranges via Azure Portal
3. Or temporarily remove IP restrictions

## 📊 Comparison Summary

| Aspect | Private Cluster | Public Cluster (IP Restricted) |
|--------|----------------|-------------------------------|
| **Security** | Highest | High (with proper IP config) |
| **Accessibility** | Complex | Simple |
| **CI/CD Integration** | Difficult | Easy |
| **Development Experience** | Poor | Excellent |
| **Setup Complexity** | High | Low |
| **Maintenance** | Complex | Simple |

## 🎯 Recommendations

### **For Development/Testing**
- Use public cluster with IP restrictions
- Include your home and office IPs
- Easy to manage and access

### **For Production**
- Consider private cluster with proper networking
- Or public cluster with very restrictive IP ranges
- Implement additional security layers (Network Security Groups, etc.)

### **Hybrid Approach**
- Development: Public cluster with IP restrictions
- Production: Private cluster with VPN/ExpressRoute

## 📚 Next Steps

1. **Deploy the changes** using the steps above
2. **Test connectivity** with `make test-connection`
3. **Configure monitoring** and logging
4. **Set up CI/CD pipelines** with the new accessible cluster
5. **Review security settings** periodically

---

**Migration Date**: $(date)  
**Cluster Type**: Public with IP Restrictions  
**Security Level**: High (when properly configured)