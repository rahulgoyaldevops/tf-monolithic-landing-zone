output "vnet_ids" {
  description = "Map of virtual networks to their resource IDs"
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.id }
}
