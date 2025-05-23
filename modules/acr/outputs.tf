output "id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group name where ACR is deployed"
  value       = azurerm_container_registry.acr.resource_group_name
}

output "location" {
  description = "Location where ACR is deployed"
  value       = azurerm_container_registry.acr.location
}

output "sku" {
  description = "SKU of the Azure Container Registry"
  value       = azurerm_container_registry.acr.sku
}