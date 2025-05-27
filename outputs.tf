output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = module.acr.name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = module.acr.login_server
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.id
}

output "acr_admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = module.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = module.acr.admin_password
  sensitive   = true
}

# AKS Outputs
output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = module.aks.cluster_private_fqdn
}

output "aks_kube_config" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = module.aks.kube_config
  sensitive   = true
}

output "aks_node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = module.aks.node_resource_group
}

output "aks_vnet_id" {
  description = "The ID of the AKS virtual network"
  value       = module.aks.vnet_id
}

output "aks_vnet_name" {
  description = "The name of the AKS virtual network"
  value       = module.aks.vnet_name
}

output "aks_nodes_subnet_id" {
  description = "The ID of the AKS nodes subnet"
  value       = module.aks.nodes_subnet_id
}

# Note: NGINX Ingress Controller outputs are now in separate nginx-ingress module
# Apply the nginx-ingress module after AKS deployment to get NGINX outputs