variable "virtual_machines" {}
variable "vm_admin_password" {
  sensitive = true
}

resource "azurerm_network_interface" "nics" {
  for_each            = var.virtual_machines
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_virtual_machine" "vm" {
  for_each              = var.virtual_machines
  name                  = each.value.vm_name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.nics[each.key].id]
  vm_size               = each.value.vm_size

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }

  storage_os_disk {
    name              = "${each.value.vm_name}-osdisk"
    caching           = each.value.caching
    create_option     = "FromImage"
    managed_disk_type = each.value.storage_account_type
  }

  os_profile {
    computer_name  = each.value.vm_name
    admin_username = each.value.admin_username
    admin_password = var.vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
