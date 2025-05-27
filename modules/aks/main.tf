# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  sku_tier            = var.sku_tier

  # Public cluster configuration with security
  private_cluster_enabled = false
  
  dynamic "api_server_access_profile" {
    for_each = var.authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.authorized_ip_ranges
    }
  }

  # Default node pool
  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.vm_size
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null

    # Use ephemeral OS disk for cost savings
    os_disk_type    = "Ephemeral"
    os_disk_size_gb = 30

    vnet_subnet_id = azurerm_subnet.aks_nodes.id
  }

  # Service Principal or Managed Identity
  identity {
    type = "SystemAssigned"
  }

  # Network profile for private networking
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    load_balancer_sku = "standard"
  }

  # RBAC configuration
  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
  }

  tags = var.tags
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "aks" {
  name                = "${var.cluster_name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Subnet for AKS nodes
resource "azurerm_subnet" "aks_nodes" {
  name                 = "${var.cluster_name}-nodes-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [var.nodes_subnet_address_prefix]
}


# Note: NGINX Ingress Controller is now installed via separate module
# after AKS cluster creation to avoid circular dependencies.
# Use the nginx-ingress module or the install script after cluster deployment.

# Role assignment for AKS to pull from ACR
# Note: This requires the service principal to have User Access Administrator role
# If deployment fails due to authorization, you can create this role assignment manually:
# az role assignment create --assignee <AKS_KUBELET_IDENTITY_OBJECT_ID> --role AcrPull --scope <ACR_RESOURCE_ID>
resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = var.enable_acr_role_assignment ? { "acr_pull" = var.acr_id } : {}

  scope                = each.value
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

# Note: RBAC permissions are managed manually via Azure Portal
# Service principal has been granted "Azure Kubernetes Service RBAC Admin" role
# on the AKS cluster for kubectl/helm operations