# 💰 Cost-Effective AKS + ACR Deployment Guide

## Quick Start for Cost Savings

### 🎯 The Problem
Running AKS infrastructure 24/7 costs ~$55-160/month even when not actively using it.

### ✅ The Solution
Deploy when needed, destroy when finished = **$0 cost when not in use**

## 🚀 Super Simple Management

### Option 1: Interactive Script (Recommended)
```bash
make quick-manage
```
This launches an interactive menu to easily deploy or destroy your infrastructure.

### Option 2: Direct Commands
```bash
# Deploy everything (2 minutes)
make dev-deploy-all

# Destroy everything (2 minutes) 
make dev-destroy
```

## 💡 Recommended Workflow

### Daily Development
```bash
# Morning: Start working
make dev-deploy-all

# Evening: Save costs
make dev-destroy
```

### Weekly Development
```bash
# Monday: Deploy for the week
make dev-deploy-all

# Friday: Destroy for weekend
make dev-destroy
```

### Demo/Presentation
```bash
# Before demo: Deploy
make dev-deploy-all

# After demo: Destroy
make dev-destroy
```

## 💰 Cost Comparison

| Usage Pattern | Monthly Cost | Savings |
|---------------|-------------|---------|
| Always Running | $55-160 | $0 |
| Weekdays Only | $40-115 | $15-45 |
| **Deploy When Needed** | **$0-20** | **$35-140** |

## 🔄 What Happens When You Deploy/Destroy

### Deploy (`make dev-deploy-all`)
- ✅ Creates AKS cluster (private, secure)
- ✅ Creates ACR for container images
- ✅ Sets up NGINX Ingress Controller
- ✅ Configures networking and security
- ⏱️ Takes ~2 minutes

### Destroy (`make dev-destroy`)
- ✅ Removes all Azure resources
- ✅ Stops all billing
- ✅ Preserves Terraform configuration
- ⏱️ Takes ~2 minutes
- ⚠️ Deletes all data and container images

## 🛡️ What's Preserved vs Lost

### Preserved (Always Safe)
- ✅ Terraform configuration files
- ✅ Kubernetes YAML manifests
- ✅ Application source code
- ✅ Infrastructure as Code setup

### Lost (When Destroyed)
- ❌ Running Kubernetes workloads
- ❌ Container images in ACR
- ❌ Persistent volume data
- ❌ Ingress configurations

## 🎯 Perfect For

- **Learning Kubernetes/AKS**
- **Demo environments**
- **Development/testing**
- **Proof of concepts**
- **Training/workshops**
- **Occasional use cases**

## 📊 Real Cost Examples

### Scenario 1: Learning AKS (2 hours/day, 5 days/week)
- Traditional: $55/month
- **With destroy pattern: ~$8/month**
- **Savings: $47/month**

### Scenario 2: Demo Environment (4 hours/week)
- Traditional: $55/month  
- **With destroy pattern: ~$3/month**
- **Savings: $52/month**

### Scenario 3: Weekend Projects (8 hours/weekend)
- Traditional: $55/month
- **With destroy pattern: ~$7/month**
- **Savings: $48/month**

## 🚀 Getting Started

1. **Clone the project**
2. **Run the interactive manager:**
   ```bash
   make quick-manage
   ```
3. **Choose "Deploy infrastructure"**
4. **Use your AKS cluster**
5. **Choose "Destroy infrastructure" when done**

## 💡 Pro Tips

### Backup Strategy
Before destroying, save important data:
```bash
# Export Kubernetes resources
kubectl get all --all-namespaces -o yaml > backup.yaml

# List ACR images
az acr repository list --name $(terraform output -raw acr_name)
```

### Quick Re-deployment
Keep your container images in a public registry (Docker Hub) or rebuild them quickly after deployment.

### Automation
Set up scripts to automatically deploy in the morning and destroy in the evening.

## 🎉 Benefits Summary

- ✅ **Zero cost** when not in use
- ✅ **Fast deployment** (2 minutes)
- ✅ **Full AKS features** when deployed
- ✅ **Private and secure** cluster
- ✅ **Perfect for demos** and learning
- ✅ **No ongoing maintenance**

---

**Bottom Line:** With this approach, you get a full production-grade AKS environment that costs almost nothing when you're not actively using it. Perfect for your use case of "deploy it again when I need it"!

**Quick Command:** `make quick-manage` - Your one-stop solution for cost-effective AKS management.