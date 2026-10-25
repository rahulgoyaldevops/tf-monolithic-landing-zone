output "rg_ids" {
  description = "Map of resource group names to their resource IDs"
  value       = { for k, v in azurerm_resource_group.rg : k => v.id }
}
