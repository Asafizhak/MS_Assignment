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

output "app_gateway_subnet_id" {
  description = "The ID of the application gateway subnet"
  value       = var.enable_application_gateway ? azurerm_subnet.app_gateway[0].id : null
}

output "app_gateway_id" {
  description = "The ID of the application gateway"
  value       = var.enable_application_gateway ? azurerm_application_gateway.main[0].id : null
}

output "app_gateway_public_ip" {
  description = "The public IP address of the application gateway"
  value       = var.enable_application_gateway ? azurerm_public_ip.app_gateway[0].ip_address : null
}