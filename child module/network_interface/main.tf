variable "nic" {
  type = map(any)
}

data "azurerm_subnet" "subnet" {
  for_each             = var.nic
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
}

data "azurerm_public_ip" "pip" {
  for_each            = { for k, v in var.nic : k => v if lookup(v, "pip_name", null) != null && lookup(v, "pip_name", null) != "" }
  name                = each.value.pip_name
  resource_group_name = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
}

resource "azurerm_network_interface" "nic" {
  for_each                      = var.nic
  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  accelerated_networking_enabled = lookup(each.value, "accelerated_networking_enabled", lookup(each.value, "enable_accelerated_networking", false))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = lookup(each.value, "private_ip_allocation", "Dynamic")
    public_ip_address_id          = lookup(each.value, "pip_name", null) != null && lookup(each.value, "pip_name", null) != "" ? data.azurerm_public_ip.pip[each.key].id : null
  }
}

