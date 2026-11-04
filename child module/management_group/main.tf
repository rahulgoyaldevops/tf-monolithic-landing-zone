# ============================================================================
# Child Module: Azure Management Group Hierarchy (Microsoft CAF Architecture)
# Author: Rahul Goyal (14+ Years Total IT | Senior DevOps Engineer)
# Conforming to Cloud Adoption Framework (CAF) Enterprise-Scale Landing Zones
# ============================================================================

variable "root_display_name" {
  type        = string
  description = "Display name for the top-level intermediate enterprise management group"
  default     = "Enterprise Root"
}

variable "root_id" {
  type        = string
  description = "Unique identifier for the top-level intermediate management group"
  default     = "mg-enterprise"
}

# ----------------------------------------------------------------------------
# 1. Top-Level Intermediate Root Management Group (CAF Recommended)
# Anchors enterprise-wide policies, RBAC, and governance without tenant pollution
# ----------------------------------------------------------------------------
resource "azurerm_management_group" "intermediate_root" {
  name         = var.root_id
  display_name = var.root_display_name
}

# ----------------------------------------------------------------------------
# 2. Platform Management Group & Sub-Tiers
# Centralized shared services for platform operations, networking, and security
# ----------------------------------------------------------------------------
resource "azurerm_management_group" "platform" {
  name                       = "${var.root_id}-platform"
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.intermediate_root.id
}

# 2a. Management: Log Analytics workspaces, Azure Monitor, Automation, Sentinel
resource "azurerm_management_group" "platform_management" {
  name                       = "${var.root_id}-platform-mgmt"
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

# 2b. Connectivity: Hub VNets, Azure Firewall, ExpressRoute/VPN, Azure DNS Resolver
resource "azurerm_management_group" "platform_connectivity" {
  name                       = "${var.root_id}-platform-conn"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# 2c. Identity: Domain Controllers, Microsoft Entra Connect, Key Vaults for identity
resource "azurerm_management_group" "platform_identity" {
  name                       = "${var.root_id}-platform-identity"
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

# ----------------------------------------------------------------------------
# 3. Landing Zones (Workloads) Management Group & Sub-Tiers
# Multi-tenant and single-tenant business application workloads
# ----------------------------------------------------------------------------
resource "azurerm_management_group" "landing_zones" {
  name                       = "${var.root_id}-landing-zones"
  display_name               = "Landing Zones"
  parent_management_group_id = azurerm_management_group.intermediate_root.id
}

# 3a. Corp: Connected workloads routed to on-prem via Hub; zero public IPs
resource "azurerm_management_group" "corp" {
  name                       = "${var.root_id}-lz-corp"
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# 3b. Online: Public/Internet-facing workloads with WAF and perimeter security
resource "azurerm_management_group" "online" {
  name                       = "${var.root_id}-lz-online"
  display_name               = "Online"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# ----------------------------------------------------------------------------
# 4. Sandboxes Management Group (CAF Isolated Experimentation)
# Strict boundary preventing any peering or connectivity to corporate VNets
# ----------------------------------------------------------------------------
resource "azurerm_management_group" "sandboxes" {
  name                       = "${var.root_id}-sandboxes"
  display_name               = "Sandboxes"
  parent_management_group_id = azurerm_management_group.intermediate_root.id
}

# ----------------------------------------------------------------------------
# 5. Decommissioned Management Group (Lifecycle Management)
# Quarantines subscriptions slated for decommission before final cancellation
# ----------------------------------------------------------------------------
resource "azurerm_management_group" "decommissioned" {
  name                       = "${var.root_id}-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = azurerm_management_group.intermediate_root.id
}
