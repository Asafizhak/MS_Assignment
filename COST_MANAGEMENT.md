# Cost Management Guide - Azure AKS + ACR Infrastructure

## 💰 Cost Overview

### Monthly Costs When Running
- **Development Environment**: ~$55 USD/month
- **Production Environment**: ~$160 USD/month

### Cost When Destroyed: $0 USD/month ✅

## 🎯 Best Practices for Cost Savings

### 1. Complete Infrastructure Destruction (Recommended)

**When to use:** When you don't need the infrastructure for days/weeks

**Commands:**
```bash
# Destroy development environment
make dev-destroy

# Destroy production environment  
make prod-destroy

# Destroy current environment (uses default variables)
make destroy
```

**What gets deleted:**
- ✅ AKS Cluster (saves ~$75/month for Standard tier)
- ✅ Virtual Machines/Node Pools (saves ~$30-60/month)
- ✅ Load Balancers (saves ~$20/month)
- ✅ Virtual Network (saves ~$0-5/month)
- ✅ ACR (saves ~$5/month)
- ⚠️ **All container images in ACR will be deleted**
- ⚠️ **All Kubernetes workloads will be deleted**

### 2. Partial Cost Reduction (Alternative)

If you want to keep ACR and container images but stop AKS:

**Option A: Stop AKS Nodes (Manual)**
```bash
# Scale node pool to 0 (keeps cluster, removes VMs)
az aks nodepool scale \
  --resource-group $(terraform output -raw resource_group_name) \
  --cluster-name $(terraform output -raw aks_cluster_name) \
  --name default \
  --node-count 0

# Scale back up when needed
az aks nodepool scale \
  --resource-group $(terraform output -raw resource_group_name) \
  --cluster-name $(terraform output -raw aks_cluster_name) \
  --name default \
  --node-count 1
```

**Savings:** ~$30-60/month (VM costs only)
**Keeps:** AKS control plane, ACR, container images

## 🔄 Recommended Workflow for Demo/Development

### Daily Development Cycle
```bash
# Morning: Deploy infrastructure
make init
make dev-deploy-all

# Work with your applications...

# Evening: Destroy to save costs
make dev-destroy
```

### Weekly Development Cycle
```bash
# Monday: Deploy for the week
make init
make dev-deploy-all

# Work throughout the week...

# Friday: Destroy for the weekend
make dev-destroy
```

## ⚡ Quick Deployment Commands

### Deploy Everything
```bash
# Development (1-2 minutes)
make dev-deploy-all

# Production (2-3 minutes)
make prod-deploy-all
```

### Destroy Everything
```bash
# Development (1-2 minutes)
make dev-destroy

# Production (2-3 minutes)
make prod-destroy
```

## 💡 Cost Optimization Tips

### 1. Use Development Environment for Testing
- Free AKS control plane
- Single node (vs 2+ in production)
- No auto-scaling overhead

### 2. Destroy When Not Actively Using
- **Overnight**: Save ~$2-5 per night
- **Weekends**: Save ~$15-30 per weekend
- **Vacation/Breaks**: Save hundreds per month

### 3. Monitor Azure Costs
```bash
# Check current costs
az consumption usage list --output table

# Set up budget alerts in Azure Portal
# Navigate to: Cost Management + Billing > Budgets
```

### 4. Use Azure Cost Management
- Set up budget alerts
- Monitor daily spending
- Review cost analysis reports

## 🚨 Important Considerations

### Data Loss Warning
When you run `make destroy`, you will lose:
- ❌ All Kubernetes workloads and data
- ❌ All container images in ACR
- ❌ All persistent volumes and data
- ❌ All ingress configurations

### Data Backup Strategy
Before destroying, consider backing up:
```bash
# Export Kubernetes configurations
kubectl get all --all-namespaces -o yaml > backup-k8s-resources.yaml

# List ACR images for reference
az acr repository list --name $(terraform output -raw acr_name) > backup-acr-images.txt

# Export Terraform state (already in remote backend)
terraform show > backup-terraform-state.txt
```

### Re-deployment Considerations
After `terraform destroy`, you'll need to:
1. Re-push container images to ACR
2. Re-deploy Kubernetes applications
3. Re-configure ingress rules
4. Re-install any additional tools/operators

## 📊 Cost Comparison

| Scenario | Monthly Cost | Use Case |
|----------|-------------|----------|
| **Always Running (Dev)** | ~$55 | Active daily development |
| **Always Running (Prod)** | ~$160 | Production workloads |
| **Weekdays Only (Dev)** | ~$40 | Part-time development |
| **Weekdays Only (Prod)** | ~$115 | Demo/testing environments |
| **Destroyed When Not Used** | **$0** | **Occasional use/learning** |

## 🎯 Recommended Approach for Your Use Case

Based on your requirement to "deploy it again when needed":

### Best Strategy: Complete Destruction
```bash
# When finished working
make dev-destroy

# When you need it again
make init
make dev-deploy-all
```

### Why This Works Best:
- ✅ **Zero cost** when not in use
- ✅ **Fast re-deployment** (1-2 minutes)
- ✅ **Fresh environment** every time
- ✅ **No maintenance** required
- ✅ **Perfect for demos** and learning

### Automation Script
Create a simple script for your workflow:

```bash
#!/bin/bash
# save as: quick-deploy.sh

echo "🚀 Quick AKS Deployment"
echo "1. Deploy infrastructure"
echo "2. Destroy infrastructure"
read -p "Choose (1/2): " choice

case $choice in
  1)
    echo "🏗️ Deploying infrastructure..."
    make init
    make dev-deploy-all
    echo "✅ Ready to use!"
    ;;
  2)
    echo "💥 Destroying infrastructure..."
    make dev-destroy
    echo "✅ Infrastructure destroyed - $0/month cost!"
    ;;
  *)
    echo "Invalid choice"
    ;;
esac
```

## 📈 Cost Monitoring Commands

```bash
# Show cost estimate
make cost-estimate

# Check what's currently deployed
make aks-info
make acr-info

# Verify destruction completed
terraform show
```

---

**💡 Pro Tip:** For maximum cost savings with your use case, always use `make dev-destroy` when finished and `make dev-deploy-all` when you need it again. This gives you $0 cost when not in use and full functionality when needed.

**⏱️ Deployment Time:** ~2 minutes to deploy, ~2 minutes to destroy
**💰 Cost Savings:** Up to $55/month when destroyed vs always running