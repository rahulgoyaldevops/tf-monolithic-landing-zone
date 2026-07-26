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

module "azurerm_public_ip" {
  depends_on = [module.azurerm_resource_group]
  source     = "../child module/pip"
  pip        = var.pip
}

# NAYA combined module — NIC + VM dono isi ke andar ban rahe hain
module "azurerm_linux_virtual_machine" {
  depends_on       = [module.azurerm_subnet, module.azurerm_public_ip]
  source           = "../child module/azurerm_linux_virtual_machine"
  virtual_machines = var.virtual_machines
  vm_admin_password = data.azurerm_key_vault_secret.vm_password.value
}