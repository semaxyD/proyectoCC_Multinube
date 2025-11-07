variable "resource_group_name" {
  description = "Name of the resource group for AKS"
  type        = string
  default     = "rg-k8s-azure"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "k8s-azure"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "k8s-azure"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS"
  type        = string
  default     = "1.33.5"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "Multinube-K8s"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Cluster     = "AKS"
  }
}
