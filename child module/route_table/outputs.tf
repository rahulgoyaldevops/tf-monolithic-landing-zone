output "route_table_ids" {
  description = "Map of route table keys to their provisioned resource IDs"
  value       = { for k, v in azurerm_route_table.rt : k => v.id }
}
