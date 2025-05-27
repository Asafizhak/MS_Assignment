output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "The kubelet identity of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "cluster_identity" {
  description = "The identity of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.identity
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.aks.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.aks.name
}

output "nodes_subnet_id" {
  description = "The ID of the nodes subnet"
  value       = azurerm_subnet.aks_nodes.id
}

# Outputs required for Helm and Kubernetes providers
output "host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

# NGINX Ingress Controller outputs
output "nginx_ingress_enabled" {
  description = "Whether NGINX Ingress Controller is enabled"
  value       = var.enable_nginx_ingress
}

output "nginx_ingress_namespace" {
  description = "The namespace where NGINX Ingress Controller is deployed"
  value       = var.enable_nginx_ingress ? kubernetes_namespace.ingress_nginx[0].metadata[0].name : null
}

output "nginx_ingress_chart_version" {
  description = "The version of NGINX Ingress Controller Helm chart"
  value       = var.enable_nginx_ingress ? var.nginx_ingress_chart_version : null
}
