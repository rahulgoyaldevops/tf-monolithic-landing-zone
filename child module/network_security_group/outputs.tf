output "nsg_ids" {
  description = "Map of NSG keys to their provisioned resource IDs"
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}
