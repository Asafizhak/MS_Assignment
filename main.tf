# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


# Data source to get current client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

# ACR Module
module "acr" {
  source = "./modules/acr"

  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.acr_sku

  tags = var.common_tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  cluster_name        = var.aks_cluster_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = var.aks_dns_prefix
  sku_tier            = var.aks_sku_tier

  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  enable_auto_scaling = var.aks_enable_auto_scaling
  min_node_count      = var.aks_min_node_count
  max_node_count      = var.aks_max_node_count

  vnet_address_space          = var.aks_vnet_address_space
  nodes_subnet_address_prefix = var.aks_nodes_subnet_address_prefix

  dns_service_ip = var.aks_dns_service_ip
  service_cidr   = var.aks_service_cidr

  enable_nginx_ingress        = var.aks_enable_nginx_ingress
  nginx_ingress_replica_count = var.aks_nginx_ingress_replica_count

  acr_id                     = module.acr.id
  enable_acr_role_assignment = var.aks_enable_acr_role_assignment
  authorized_ip_ranges       = var.aks_authorized_ip_ranges
  tags                       = var.common_tags

  depends_on = [module.acr]
}