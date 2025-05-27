terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }

  # Backend configuration for remote state storage
  backend "azurerm" {
    # These values can be provided via:
    # 1. Environment variables (ARM_*)
    # 2. Command line (-backend-config)
    # 3. Backend configuration file
    # 4. Uncomment and set directly (not recommended for production)
  }
}