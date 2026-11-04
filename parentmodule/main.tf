# ============================================================================
# Enterprise Landing Zone Root Orchestrator
# Author: Rahul Goyal (14+ Years Total IT | Senior DevOps Engineer)
# ============================================================================

# Optional Enterprise CAF Management Group Hierarchy
module "azurerm_management_group_hierarchy" {
  count             = var.deploy_management_groups ? 1 : 0
  source            = "../child module/management_group"
  root_id           = var.mg_root_id
  root_display_name = var.mg_root_display_name
}

module "azurerm_resource_group" {
  source = "../child module/resource_group"
  rgs    = var.rgs
}

module "azurerm_virtual_network" {
  depends_on = [module.azurerm_resource_group]
  source     = "../child module/virtual_network"
  vnet       = var.vnet
}

module "azurerm_subnet" {
  depends_on = [module.azurerm_virtual_network]
  source     = "../child module/subnet"
  subnet     = var.subnet
}

# Network Security Groups & Subnet Associations
module "azurerm_network_security_group" {
  depends_on = [module.azurerm_subnet]
  source     = "../child module/network_security_group"
  nsgs = {
    for k, v in var.nsgs : k => merge(v, {
      subnet_id = lookup(v, "subnet_key", null) != null ? lookup(module.azurerm_subnet.subnet_ids, v.subnet_key, null) : lookup(v, "subnet_id", null)
    })
  }
}

# Route Tables (UDR) & Subnet Associations (Zero-Trust Forced Tunneling)
module "azurerm_route_table" {
  depends_on = [module.azurerm_subnet]
  source     = "../child module/route_table"
  route_tables = {
    for k, v in var.route_tables : k => merge(v, {
      subnet_id = lookup(v, "subnet_key", null) != null ? lookup(module.azurerm_subnet.subnet_ids, v.subnet_key, null) : lookup(v, "subnet_id", null)
    })
  }
}

module "azurerm_public_ip" {
  depends_on = [module.azurerm_resource_group]
  source     = "../child module/pip"
  pip        = var.pip
}

# Core Workload Virtual Machine & Associated NIC provisioning
module "azurerm_linux_virtual_machine" {
  depends_on        = [module.azurerm_subnet, module.azurerm_public_ip, module.azurerm_network_security_group, module.azurerm_route_table]
  source            = "../child module/azurerm_linux_virtual_machine"
  virtual_machines  = var.virtual_machines
  vm_admin_password = data.azurerm_key_vault_secret.vm_password.value
}
