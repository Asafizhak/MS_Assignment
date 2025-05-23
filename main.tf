# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  # Backend configuration for remote state storage
  backend "azurerm" {
    # These values will be provided via GitHub Actions
    # resource_group_name  = "tfstate-rg"
    # storage_account_name = "tfstatestorage"
    # container_name       = "tfstate"
    # key                  = "terraform.tfstate"
  }
}

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
  location           = azurerm_resource_group.main.location
  sku                = var.acr_sku
  
  tags = var.common_tags
}