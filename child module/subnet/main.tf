variable "subnet" {
  type = map(any)
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnet
  name                 = each.value.name
  virtual_network_name = lookup(each.value, "virtual_network_name", lookup(each.value, "vnet_name", null))
  resource_group_name  = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  address_prefixes     = each.value.address_prefixes
}
