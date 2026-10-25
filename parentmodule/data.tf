# ============================================================================
# Centralized Key Vault & Bootstrap Credentials Data Sources
# ============================================================================

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = var.vm_secret_name
  key_vault_id = data.azurerm_key_vault.kv.id
}
