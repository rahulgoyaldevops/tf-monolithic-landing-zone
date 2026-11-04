output "management_group_ids" {
  description = "Resource IDs for each CAF Enterprise Management Group tier"
  value = {
    intermediate_root     = azurerm_management_group.intermediate_root.id
    platform              = azurerm_management_group.platform.id
    platform_management   = azurerm_management_group.platform_management.id
    platform_connectivity = azurerm_management_group.platform_connectivity.id
    platform_identity     = azurerm_management_group.platform_identity.id
    landing_zones         = azurerm_management_group.landing_zones.id
    corp                  = azurerm_management_group.corp.id
    online                = azurerm_management_group.online.id
    sandboxes             = azurerm_management_group.sandboxes.id
    decommissioned        = azurerm_management_group.decommissioned.id
  }
}
