# ============================================================================
# Enterprise Landing Zone Engineering Outputs
# ============================================================================

output "landing_zone_summary" {
  description = "Executive topology summary of the deployed Azure Landing Zone"
  value = {
    environment        = var.environment
    resource_group_id  = module.azurerm_resource_group.rg_ids
    virtual_network_id = module.azurerm_virtual_network.vnet_ids
    subnets            = module.azurerm_subnet.subnet_ids
    public_ips         = module.azurerm_public_ip.pip_ids
    governance_tags    = local.mandatory_tags
  }
}

output "hub_egress_firewall_private_ip" {
  description = "Next hop private IP address for spoke User Defined Routes (UDR)"
  value       = "10.100.1.4"
}

output "key_vault_secret_reference" {
  description = "Key Vault secret reference for secure VM administrator bootstrapping"
  value       = data.azurerm_key_vault_secret.vm_password.id
  sensitive   = true
}