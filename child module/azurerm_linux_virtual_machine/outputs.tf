output "vm_ids" {
  description = "Map of virtual machines to their resource IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_principal_ids" {
  description = "System Assigned Identity principal IDs for RBAC assignment"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.identity[0].principal_id }
}
