#!/bin/bash

# Script to install NGINX Ingress Controller on AKS cluster
# This script should be run after the AKS cluster is deployed

set -e

echo "🚀 Installing NGINX Ingress Controller on AKS cluster..."

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Helm is not installed. Please install Helm first."
    exit 1
fi

# Get AKS credentials (replace with your actual cluster name and resource group)
CLUSTER_NAME=${1:-"aks-demo-dev"}
RESOURCE_GROUP=${2:-"rg-acr-aks-demo-dev"}

echo "📋 Getting AKS credentials for cluster: $CLUSTER_NAME in resource group: $RESOURCE_GROUP"
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

# Verify connection to cluster
echo "🔍 Verifying connection to AKS cluster..."
kubectl cluster-info

# Create namespace for ingress-nginx
echo "📦 Creating ingress-nginx namespace..."
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

# Add the ingress-nginx repository
echo "📚 Adding NGINX Ingress Helm repository..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
echo "⚙️ Installing NGINX Ingress Controller..."
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.service.type=LoadBalancer \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=true \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.resources.requests.cpu=100m \
    --set controller.resources.requests.memory=128Mi \
    --set controller.resources.limits.cpu=200m \
    --set controller.resources.limits.memory=256Mi \
    --wait

# Wait for the ingress controller to be ready
echo "⏳ Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=300s

# Get the internal load balancer IP
echo "🔍 Getting NGINX Ingress Controller service details..."
kubectl get service nginx-ingress-ingress-nginx-controller --namespace ingress-nginx

echo "✅ NGINX Ingress Controller installation completed!"
echo ""
echo "📝 Next steps:"
echo "1. The ingress controller is configured with an internal load balancer"
echo "2. You can now create Ingress resources to route traffic to your applications"
echo "3. Example Ingress resource:"
echo ""
cat << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
EOF