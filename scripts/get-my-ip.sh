#!/bin/bash

# Script to get your current public IP address for AKS authorized IP ranges
# This helps secure your public AKS cluster by restricting API access

echo "🔍 Getting your current public IP address..."
echo ""

# Method 1: Using curl with ipinfo.io
echo "Method 1 - ipinfo.io:"
PUBLIC_IP1=$(curl -s https://ipinfo.io/ip 2>/dev/null)
if [ ! -z "$PUBLIC_IP1" ]; then
    echo "  Your public IP: $PUBLIC_IP1"
    echo "  CIDR format: $PUBLIC_IP1/32"
else
    echo "  ❌ Failed to get IP from ipinfo.io"
fi

echo ""

# Method 2: Using curl with ifconfig.me
echo "Method 2 - ifconfig.me:"
PUBLIC_IP2=$(curl -s https://ifconfig.me 2>/dev/null)
if [ ! -z "$PUBLIC_IP2" ]; then
    echo "  Your public IP: $PUBLIC_IP2"
    echo "  CIDR format: $PUBLIC_IP2/32"
else
    echo "  ❌ Failed to get IP from ifconfig.me"
fi

echo ""

# Method 3: Using Azure CLI (if available)
echo "Method 3 - Azure CLI:"
if command -v az &> /dev/null; then
    AZURE_IP=$(az rest --method get --url 'https://api.ipify.org?format=json' --query 'ip' -o tsv 2>/dev/null)
    if [ ! -z "$AZURE_IP" ]; then
        echo "  Your public IP: $AZURE_IP"
        echo "  CIDR format: $AZURE_IP/32"
    else
        echo "  ❌ Failed to get IP via Azure CLI"
    fi
else
    echo "  ⚠️  Azure CLI not available"
fi

echo ""
echo "📋 Usage Instructions:"
echo ""
echo "1. Copy one of the IP addresses above"
echo "2. Add it to your terraform.tfvars file:"
echo "   aks_authorized_ip_ranges = [\"YOUR_IP/32\"]"
echo ""
echo "3. Or set it as an environment variable:"
echo "   export TF_VAR_aks_authorized_ip_ranges='[\"YOUR_IP/32\"]'"
echo ""
echo "4. For multiple IPs (office, home, etc.):"
echo "   aks_authorized_ip_ranges = [\"IP1/32\", \"IP2/32\", \"OFFICE_RANGE/24\"]"
echo ""
echo "⚠️  Note: If you don't set authorized_ip_ranges, the cluster will be"
echo "   accessible from any IP address on the internet."
echo ""
echo "🔒 For maximum security, always specify your IP ranges!"