variable "name" {
  description = "Name of the Azure Container Registry"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.name))
    error_message = "ACR name must contain only alphanumeric characters."
  }
  
  validation {
    condition     = length(var.name) >= 5 && length(var.name) <= 50
    error_message = "ACR name must be between 5 and 50 characters."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "sku" {
  description = "SKU for the Azure Container Registry"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the ACR"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access for the ACR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the ACR"
  type        = map(string)
  default     = {}
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the ACR (Premium SKU only)"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}