variable "pip" {
  type = map(any)
}

resource "azurerm_public_ip" "pip" {
  for_each            = var.pip
  name                = each.value.name
  resource_group_name = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  location            = each.value.location
  allocation_method   = lookup(each.value, "allocation_method", "Static")
  sku                 = lookup(each.value, "sku", "Standard")
  zones               = lookup(each.value, "zones", ["1", "2", "3"])
}
