# NGINX Ingress Controller - Terraform Integration

## 🚀 Overview

NGINX Ingress Controller is now **automatically installed** as part of your AKS cluster deployment using Terraform. No more manual installation steps required!

## 📋 Changes Made

### 1. **Added Required Providers**
**File**: [`versions.tf`](versions.tf)

```hcl
required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 3.0"
  }
  helm = {
    source  = "hashicorp/helm"
    version = "~> 2.0"
  }
  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.0"
  }
}
```

### 2. **Added Provider Configurations**
**File**: [`main.tf`](main.tf)

```hcl
# Configure the Helm Provider
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}
```

### 3. **Added NGINX Ingress Resources**
**File**: [`modules/aks/main.tf`](modules/aks/main.tf)

```hcl
# Kubernetes namespace for NGINX Ingress Controller
resource "kubernetes_namespace" "ingress_nginx" {
  count = var.enable_nginx_ingress ? 1 : 0
  
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}

# NGINX Ingress Controller Helm Release
resource "helm_release" "nginx_ingress" {
  count = var.enable_nginx_ingress ? 1 : 0

  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_ingress_chart_version
  namespace  = kubernetes_namespace.ingress_nginx[0].metadata[0].name

  # Controller configuration with internal load balancer
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  set {
    name  = "controller.replicaCount"
    value = var.nginx_ingress_replica_count
  }

  # Resource optimization
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "256Mi"
  }

  wait          = true
  wait_for_jobs = true
  timeout       = 600

  depends_on = [
    azurerm_kubernetes_cluster.main,
    kubernetes_namespace.ingress_nginx
  ]
}
```

### 4. **Added Required Outputs**
**Files**: [`modules/aks/outputs.tf`](modules/aks/outputs.tf), [`outputs.tf`](outputs.tf)

```hcl
# Provider connection outputs
output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive   = true
}

# NGINX Ingress outputs
output "nginx_ingress_enabled" {
  description = "Whether NGINX Ingress Controller is enabled"
  value       = var.enable_nginx_ingress
}
```

### 5. **Updated Makefile**
**File**: [`Makefile`](Makefile)

- Updated `nginx-install` command to reflect automated installation
- Modified deployment workflows to remove manual NGINX installation steps
- Added status checks after deployment

### 6. **Updated Documentation**
**File**: [`AKS_DEPLOYMENT_GUIDE.md`](AKS_DEPLOYMENT_GUIDE.md)

- Updated deployment steps to reflect automated NGINX installation
- Added configuration variables documentation
- Updated troubleshooting section

## 🎯 Benefits of Terraform Integration

### **Before (Manual Installation)**
- ❌ Required manual post-deployment steps
- ❌ Potential for human error
- ❌ Inconsistent deployments
- ❌ Complex CI/CD integration

### **After (Terraform Automation)**
- ✅ **Fully Automated**: NGINX installs with AKS cluster
- ✅ **Consistent**: Same configuration every time
- ✅ **Version Controlled**: Configuration tracked in Git
- ✅ **CI/CD Ready**: No manual intervention required
- ✅ **Declarative**: Infrastructure as Code principles

## 🔧 Configuration Variables

Control NGINX Ingress installation through these variables:

```hcl
# Enable/disable NGINX Ingress Controller
aks_enable_nginx_ingress = true

# Number of NGINX controller replicas
aks_nginx_ingress_replica_count = 1

# Helm chart version
nginx_ingress_chart_version = "4.8.3"
```

## 🚀 Deployment Workflow

### **New Simplified Workflow**

```bash
# 1. Deploy everything (AKS + NGINX automatically)
make dev-apply

# 2. Get cluster credentials
make aks-creds

# 3. Verify NGINX installation (automatic)
make nginx-status
```

### **What Happens Automatically**

1. **AKS Cluster** is created
2. **Kubernetes Namespace** `ingress-nginx` is created
3. **NGINX Ingress Controller** is installed via Helm
4. **Azure Load Balancer** is created automatically
5. **Internal IP** is assigned from VNet range

## 📊 Verification Commands

```bash
# Check NGINX pods
kubectl get pods -n ingress-nginx

# Check NGINX services
kubectl get svc -n ingress-nginx

# Check Helm releases
helm list -n ingress-nginx

# View Terraform outputs
terraform output nginx_ingress_enabled
```

## 🔒 Security Configuration

NGINX Ingress Controller is configured with:

- **Internal Load Balancer**: Traffic stays within VNet
- **Resource Limits**: CPU and memory constraints for cost optimization
- **Linux Node Selector**: Ensures pods run on Linux nodes
- **Namespace Isolation**: Deployed in dedicated `ingress-nginx` namespace

## 🎉 Migration Complete

Your NGINX Ingress Controller is now fully integrated into your Terraform infrastructure. The next time you deploy your AKS cluster, NGINX will be installed automatically without any manual intervention required!

## 📚 Next Steps

1. **Deploy the updated infrastructure**: `make dev-apply`
2. **Verify NGINX installation**: `make nginx-status`
3. **Create Ingress resources** for your applications
4. **Test traffic routing** through the internal load balancer

---

**Integration Date**: $(date)  
**Status**: ✅ Complete  
**Installation Method**: Terraform Helm Provider  
**Manual Steps Required**: None