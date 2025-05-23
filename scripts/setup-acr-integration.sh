#!/bin/bash

# Script to manually set up ACR integration with AKS
# This script should be run after both ACR and AKS are deployed
# if the automatic role assignment failed due to insufficient permissions

set -e

echo "🔗 Setting up ACR integration with AKS cluster..."

# Get resource information from Terraform outputs
echo "📋 Getting resource information from Terraform..."

ACR_ID=$(terraform output -raw acr_id 2>/dev/null || echo "")
AKS_CLUSTER_NAME=$(terraform output -raw aks_cluster_name 2>/dev/null || echo "")
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "")

if [ -z "$ACR_ID" ] || [ -z "$AKS_CLUSTER_NAME" ] || [ -z "$RESOURCE_GROUP" ]; then
    echo "❌ Could not get required information from Terraform outputs."
    echo "Please ensure both ACR and AKS are deployed successfully."
    exit 1
fi

echo "✅ Found resources:"
echo "   ACR ID: $ACR_ID"
echo "   AKS Cluster: $AKS_CLUSTER_NAME"
echo "   Resource Group: $RESOURCE_GROUP"

# Get AKS kubelet identity
echo "🔍 Getting AKS kubelet identity..."
KUBELET_IDENTITY=$(az aks show --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --query "identityProfile.kubeletidentity.objectId" -o tsv)

if [ -z "$KUBELET_IDENTITY" ]; then
    echo "❌ Could not get AKS kubelet identity."
    exit 1
fi

echo "✅ AKS Kubelet Identity: $KUBELET_IDENTITY"

# Create role assignment
echo "🔐 Creating ACR pull role assignment..."
az role assignment create \
    --assignee "$KUBELET_IDENTITY" \
    --role "AcrPull" \
    --scope "$ACR_ID"

if [ $? -eq 0 ]; then
    echo "✅ ACR integration setup completed successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. Your AKS cluster can now pull images from ACR"
    echo "2. Use the ACR login server in your Kubernetes manifests:"
    echo "   $(terraform output -raw acr_login_server 2>/dev/null || echo 'your-acr-name.azurecr.io')"
    echo ""
    echo "Example deployment:"
    echo "apiVersion: apps/v1"
    echo "kind: Deployment"
    echo "metadata:"
    echo "  name: my-app"
    echo "spec:"
    echo "  replicas: 1"
    echo "  selector:"
    echo "    matchLabels:"
    echo "      app: my-app"
    echo "  template:"
    echo "    metadata:"
    echo "      labels:"
    echo "        app: my-app"
    echo "    spec:"
    echo "      containers:"
    echo "      - name: my-app"
    echo "        image: $(terraform output -raw acr_login_server 2>/dev/null || echo 'your-acr-name.azurecr.io')/my-app:latest"
    echo "        ports:"
    echo "        - containerPort: 80"
else
    echo "❌ Failed to create role assignment."
    echo "Please check your Azure permissions and try again."
    exit 1
fi