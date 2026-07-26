data "azurerm_key_vault" "kv" {
  name                = "rgdevopskv001"
  resource_group_name = "sparten-rg"   # jis RG mein key vault hai
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}