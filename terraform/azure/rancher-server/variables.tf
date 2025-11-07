variable "resource_group_name" {
  description = "Name of the resource group for Rancher"
  type        = string
  default     = "rg-rancher-server"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "rancher"
}

variable "vm_size" {
  description = "Size of the Rancher VM"
  type        = string
  default     = "Standard_D2s_v3" # 2 vCPU, 8GB RAM
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "rancher_version" {
  description = "Version of Rancher to deploy"
  type        = string
  default     = "v2.8.3"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "Multinube-K8s"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
