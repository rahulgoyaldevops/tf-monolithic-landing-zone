output "pip_ids" {
  description = "Map of public IPs to their resource IDs"
  value       = { for k, v in azurerm_public_ip.pip : k => v.id }
}
