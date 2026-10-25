variable "vnet" {
  type = map(any)
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet
  name                = each.value.name
  location            = each.value.location
  resource_group_name = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  address_space       = each.value.address_space
  dns_servers         = lookup(each.value, "dns_servers", null)
}
