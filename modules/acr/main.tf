# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Enable admin user for basic authentication (useful for demos)
  admin_enabled = true

  # Public network access (can be restricted in production)
  public_network_access_enabled = true

  # Network rule set for Basic SKU (limited options)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      default_action = "Allow"
    }
  }

  tags = var.tags
}

# Optional: Create a private endpoint (only available for Premium SKU)
# resource "azurerm_private_endpoint" "acr" {
#   count               = var.sku == "Premium" && var.enable_private_endpoint ? 1 : 0
#   name                = "${var.name}-pe"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id
#
#   private_service_connection {
#     name                           = "${var.name}-psc"
#     private_connection_resource_id = azurerm_container_registry.acr.id
#     subresource_names              = ["registry"]
#     is_manual_connection           = false
#   }
#
#   tags = var.tags
# }