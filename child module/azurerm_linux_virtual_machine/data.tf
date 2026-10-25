data "azurerm_subnet" "subnet" {
  for_each             = var.virtual_machines
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

# Production Standard: Workload VMs should NOT have Public IPs attached.
# Only lookup Public IP if explicitly specified (e.g. for Bastion/Testing).
data "azurerm_public_ip" "pip" {
  for_each            = { for k, v in var.virtual_machines : k => v if lookup(v, "pip_name", null) != null && lookup(v, "pip_name", null) != "" }
  name                = each.value.pip_name
  resource_group_name = each.value.resource_group_name
}