output "nic_ids" {
  description = "Map of NICs to their resource IDs"
  value       = { for k, v in azurerm_network_interface.nic : k => v.id }
}
