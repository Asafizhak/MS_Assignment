# Azure Kubernetes Service (AKS) Deployment Guide

## Overview

This guide covers the deployment of Azure Kubernetes Service (AKS) with NGINX Ingress Controller in a private network configuration, integrated with Azure Container Registry (ACR).

## Architecture

### Components Deployed

1. **Azure Container Registry (ACR)** - Basic SKU for cost optimization
2. **Azure Kubernetes Service (AKS)** - Private cluster with system-assigned managed identity
3. **Virtual Network** - Custom VNet with dedicated subnets
4. **NGINX Ingress Controller** - Internal load balancer configuration
5. **Role Assignments** - ACR pull permissions for AKS (automatically configured)

### Network Configuration

- **VNet Address Space**: `10.0.0.0/16`
- **AKS Nodes Subnet**: `10.0.1.0/24`
- **App Gateway Subnet**: `10.0.2.0/24` (reserved for future use)
- **Service CIDR**: `10.1.0.0/16`
- **DNS Service IP**: `10.1.0.10`

## Security Features

### Private Cluster Configuration

- ✅ **Private API Server**: Cluster API server is not exposed to the internet
- ✅ **Private DNS Zone**: Uses system-managed private DNS zone
- ✅ **Internal Load Balancer**: NGINX Ingress uses internal Azure Load Balancer
- ✅ **Network Policies**: Azure CNI with Azure Network Policy
- ✅ **RBAC Enabled**: Role-based access control with Azure AD integration

### Cost Optimization

- **AKS SKU**: Free tier for development, Standard for production
- **Node Pool**: Single node (dev) or 2 nodes (prod) with `Standard_B2s` VMs
- **Ephemeral OS Disks**: Reduces storage costs
- **Auto-scaling**: Disabled for dev, enabled for prod (2-5 nodes)

## Deployment Instructions

### Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 1.5.0
3. **kubectl** for Kubernetes management
4. **Helm** for package management
5. **Azure subscription** with appropriate permissions

### Step 1: Deploy Infrastructure

```bash
# Clone the repository
git clone <repository-url>
cd azure-aks-terraform

# Initialize Terraform
make init

# Plan deployment (development)
make dev-plan

# Deploy infrastructure
make dev-apply
```

### Step 2: Configure kubectl

```bash
# Get AKS credentials
make aks-creds

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Step 3: Verify NGINX Ingress Controller (Automatically Installed)

```bash
# NGINX Ingress Controller is now installed automatically via Terraform!
# Check installation status
make nginx-status

# View NGINX pods and services
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Step 4: Verify Deployment

```bash
# Check all resources
make aks-info

# View cluster nodes
make aks-nodes

# Check ingress controller
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

### Step 5: Verify ACR Integration

```bash
# Check ACR role assignment
az role assignment list --scope $(terraform output -raw acr_id) --query "[?roleDefinitionName=='AcrPull']"

# Test pulling from ACR (example)
kubectl run test-acr --image=$(terraform output -raw acr_login_server)/hello-world:latest --rm -it --restart=Never
```

## Environment Configurations

### Development Environment

```hcl
# environments/dev.tfvars
aks_cluster_name     = "aks-demo-dev"
aks_sku_tier         = "Free"
aks_node_count       = 1
aks_vm_size          = "Standard_B2s"
aks_enable_auto_scaling = false
```

### Production Environment

```hcl
# environments/prod.tfvars
aks_cluster_name     = "aks-demo-prod"
aks_sku_tier         = "Standard"
aks_node_count       = 2
aks_vm_size          = "Standard_B2s"
aks_enable_auto_scaling = true
aks_min_node_count   = 2
aks_max_node_count   = 5
```

## NGINX Ingress Configuration

### Automated Installation via Terraform

The NGINX Ingress Controller is now **automatically installed** during AKS cluster deployment using Terraform Helm provider with the following configuration:

- **Installation Method**: Terraform Helm resource (no manual steps required)
- **Service Type**: LoadBalancer with internal Azure Load Balancer
- **Internal Annotation**: `service.beta.kubernetes.io/azure-load-balancer-internal: "true"`
- **Resource Limits**: CPU 100m-200m requests/limits, Memory 128Mi-256Mi
- **Node Selector**: Linux nodes only
- **Replica Count**: Configurable via `aks_nginx_ingress_replica_count` variable
- **Chart Version**: Configurable via `nginx_ingress_chart_version` variable
- **Namespace**: `ingress-nginx` (created automatically)

### Configuration Variables

Control NGINX Ingress installation through Terraform variables:

```hcl
# Enable/disable NGINX Ingress Controller
aks_enable_nginx_ingress = true

# Number of NGINX controller replicas
aks_nginx_ingress_replica_count = 1

# Helm chart version (optional)
nginx_ingress_chart_version = "4.8.3"
```

### Example Ingress Resource

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-app
  namespace: default
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app.internal.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

## Troubleshooting

### Common Issues

1. **kubectl connection issues**
   ```bash
   # Re-configure credentials
   make aks-creds
   ```

2. **NGINX Ingress not starting**
   ```bash
   # Check pod logs
   kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
   ```

3. **ACR pull issues**
   ```bash
   # Verify role assignment (should be automatically created)
   az role assignment list --scope $(terraform output -raw acr_id)
   
   # If role assignment is missing, run the setup script
   ./scripts/setup-acr-integration.sh
   ```

### Validation Commands

```bash
# Check cluster health
kubectl get nodes -o wide
kubectl get pods --all-namespaces

# Verify network connectivity
kubectl run test-pod --image=nginx --rm -it -- /bin/bash

# Test ingress controller
kubectl get svc -n ingress-nginx
```

## Monitoring and Maintenance

### Recommended Monitoring

1. **Azure Monitor for Containers** - Enable container insights
2. **Prometheus + Grafana** - Custom metrics and dashboards
3. **Azure Log Analytics** - Centralized logging

### Maintenance Tasks

- **Node Updates**: Managed automatically by AKS
- **Kubernetes Version**: Plan regular upgrades
- **Security Patches**: Monitor Azure Security Center recommendations

## Cost Estimation

### Monthly Costs (Approximate)

**Development Environment:**
- AKS Control Plane: Free
- 1x Standard_B2s Node: ~$30
- Load Balancer: ~$20
- **Total**: ~$50/month

**Production Environment:**
- AKS Control Plane: ~$75
- 2x Standard_B2s Nodes: ~$60
- Load Balancer: ~$20
- **Total**: ~$155/month

## Next Steps

1. **Application Deployment**: Deploy your containerized applications
2. **SSL/TLS Configuration**: Configure HTTPS with cert-manager
3. **Monitoring Setup**: Implement comprehensive monitoring
4. **Backup Strategy**: Configure cluster and persistent volume backups
5. **CI/CD Integration**: Set up automated deployments

## Security Considerations

### Production Hardening

- [ ] Enable Azure Policy for AKS
- [ ] Configure Pod Security Standards
- [ ] Implement network segmentation
- [ ] Enable audit logging
- [ ] Configure Azure Key Vault integration
- [ ] Set up vulnerability scanning

### Access Control

- [ ] Configure Azure AD integration
- [ ] Implement RBAC policies
- [ ] Set up service accounts with minimal permissions
- [ ] Enable admission controllers

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Azure AKS documentation
3. Check NGINX Ingress Controller documentation
4. Use `make help` for available commands

## References.

- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)