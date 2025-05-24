variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-acr-demo"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acrmsassignment2025"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name))
    error_message = "ACR name must contain only alphanumeric characters."
  }
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "acr-terraform"
    ManagedBy   = "terraform"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

# AKS Variables
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-demo-cluster"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-demo"
}

variable "aks_sku_tier" {
  description = "SKU tier for the AKS cluster"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.aks_sku_tier)
    error_message = "AKS SKU tier must be Free or Standard."
  }
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "aks_vm_size" {
  description = "Size of the Virtual Machine for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_enable_auto_scaling" {
  description = "Enable auto scaling for the AKS default node pool"
  type        = bool
  default     = false
}

variable "aks_min_node_count" {
  description = "Minimum number of nodes when auto scaling is enabled"
  type        = number
  default     = 1
}

variable "aks_max_node_count" {
  description = "Maximum number of nodes when auto scaling is enabled"
  type        = number
  default     = 3
}

variable "aks_vnet_address_space" {
  description = "Address space for the AKS virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_nodes_subnet_address_prefix" {
  description = "Address prefix for the AKS nodes subnet"
  type        = string
  default     = "10.0.1.0/24"
}


variable "aks_dns_service_ip" {
  description = "IP address within the Kubernetes service address range for cluster service discovery"
  type        = string
  default     = "10.1.0.10"
}

variable "aks_service_cidr" {
  description = "The Network Range used by the Kubernetes service"
  type        = string
  default     = "10.1.0.0/16"
}


variable "aks_enable_nginx_ingress" {
  description = "Enable NGINX Ingress Controller for AKS"
  type        = bool
  default     = true
}

variable "aks_nginx_ingress_replica_count" {
  description = "Number of NGINX Ingress Controller replicas"
  type        = number
  default     = 1
}

variable "aks_enable_acr_role_assignment" {
  description = "Enable automatic ACR role assignment (requires User Access Administrator permissions)"
  type        = bool
  default     = false
}

variable "aks_authorized_ip_ranges" {
  description = "List of authorized IP ranges that can access the AKS API server (leave null for unrestricted access)"
  type        = list(string)
  default     = null

  validation {
    condition = var.aks_authorized_ip_ranges == null || alltrue([
      for ip in coalesce(var.aks_authorized_ip_ranges, []) : can(cidrhost(ip, 0))
    ])
    error_message = "All IP ranges must be valid CIDR blocks (e.g., '203.0.113.0/24' or '203.0.113.5/32')."
  }
}