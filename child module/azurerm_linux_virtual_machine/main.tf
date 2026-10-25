variable "virtual_machines" {
  type = map(any)
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

resource "azurerm_network_interface" "nics" {
  for_each                      = var.virtual_machines
  name                          = lookup(each.value, "nic_name", "${lookup(each.value, "name", lookup(each.value, "vm_name", each.key))}-nic")
  location                      = each.value.location
  resource_group_name           = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  accelerated_networking_enabled = lookup(each.value, "accelerated_networking_enabled", lookup(each.value, "enable_accelerated_networking", true))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"

    # Enterprise Zero-Trust Rule: In production, VMs NEVER have Public IPs directly attached.
    # Outbound egress routes via Azure Firewall/NAT Gateway; Inbound routes via Application Gateway/Bastion.
    public_ip_address_id          = lookup(each.value, "pip_name", null) != null && lookup(each.value, "pip_name", null) != "" ? data.azurerm_public_ip.pip[each.key].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.virtual_machines
  name                            = lookup(each.value, "name", lookup(each.value, "vm_name", each.key))
  location                        = each.value.location
  resource_group_name             = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  network_interface_ids           = [azurerm_network_interface.nics[each.key].id]
  size                            = lookup(each.value, "size", lookup(each.value, "vm_size", "Standard_D4s_v5"))
  admin_username                  = lookup(each.value, "admin_username", "azureadmin")
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "${lookup(each.value, "name", lookup(each.value, "vm_name", each.key))}-osdisk"
    caching              = lookup(each.value, "caching", "ReadWrite")
    storage_account_type = lookup(each.value, "storage_account_type", "StandardSSD_LRS")
  }

  source_image_reference {
    publisher = lookup(each.value, "publisher", "Canonical")
    offer     = lookup(each.value, "offer", "0001-com-ubuntu-server-jammy")
    sku       = lookup(each.value, "sku", "22_04-lts-gen2")
    version   = lookup(each.value, "version", "latest")
  }

  # Zero-Trust Managed Identity for keyless access to Azure Key Vault & Storage
  identity {
    type = "SystemAssigned"
  }
}

