output "subnet_ids" {
  description = "Map of subnets to their resource IDs"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}
