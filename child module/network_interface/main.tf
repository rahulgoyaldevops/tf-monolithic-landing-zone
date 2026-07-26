variable "nic" {}
resource "azurerm_network_interface" "public_ip" {
  for_each            = var.nic
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.public_ip[each.key].id
  }
}

data "azurerm_public_ip" "public_ip" {
  for_each = var.nic

  name                = each.value.pip_name
  resource_group_name = each.value.resource_group_name
}
data "azurerm_subnet" "subnet" {
  for_each = var.nic

  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

