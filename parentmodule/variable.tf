# ============================================================================
# Input Variable Definitions with Enterprise Type Constraints & Defaults
# ============================================================================

variable "environment" {
  type        = string
  description = "Target deployment environment tier (dev, uat, staging, prod)"
  default     = "prod"
}

variable "project_name" {
  type        = string
  description = "Application or platform domain identifier"
  default     = "core-platform"
}

variable "location_short" {
  type        = string
  description = "Abbreviated region code conforming to enterprise CAF naming (e.g. inc, inw, eus)"
  default     = "inc"
}

variable "location" {
  type        = string
  description = "Azure physical primary deployment region"
  default     = "Central India"
}

variable "cost_center" {
  type        = string
  description = "FinOps accounting and chargeback allocation code"
  default     = "CC-INFRA-PROD-01"
}

variable "data_sensitivity" {
  type        = string
  description = "Data classification category (Public, Internal, Confidential, Restricted)"
  default     = "Confidential"
}

variable "custom_tags" {
  type        = map(string)
  description = "Additional workload-specific metadata tags to append to base governance tags"
  default     = {}
}

variable "key_vault_name" {
  type        = string
  description = "Name of the existing centralized Azure Key Vault"
  default     = "rgdevopskv001"
}

variable "key_vault_rg" {
  type        = string
  description = "Resource Group hosting the centralized Azure Key Vault"
  default     = "sparten-rg"
}

variable "vm_secret_name" {
  type        = string
  description = "Key Vault secret key holding VM administrative bootstrapping password"
  default     = "vm-admin-password"
}

variable "rgs" {
  type        = map(any)
  description = "Map of resource groups to be provisioned across environments"
}

variable "vnet" {
  type        = map(any)
  description = "Map of virtual networks with CIDR prefixes and DNS configurations"
}

variable "subnet" {
  type        = map(any)
  description = "Map of subnets for network microsegmentation and routing"
}

variable "pip" {
  type        = map(any)
  description = "Map of Standard SKU Public IP addresses for perimeter egress / ingress"
}

variable "virtual_machines" {
  type        = map(any)
  description = "Map of enterprise Linux virtual machine workloads"
}

variable "nsgs" {
  type        = map(any)
  description = "Map of Network Security Groups with rules and subnet associations"
  default     = {}
}

variable "route_tables" {
  type        = map(any)
  description = "Map of Route Tables with UDR routes and subnet associations"
  default     = {}
}
variable "deploy_management_groups" {
  type        = bool
  description = "Flag to enable provision of the Microsoft CAF Enterprise-Scale Management Group hierarchy"
  default     = false
}

variable "mg_root_id" {
  type        = string
  description = "Root ID for the intermediate enterprise management group"
  default     = "mg-enterprise"
}

variable "mg_root_display_name" {
  type        = string
  description = "Display name for the intermediate enterprise management group"
  default     = "Enterprise Root"
}
