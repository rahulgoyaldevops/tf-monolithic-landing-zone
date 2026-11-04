# ============================================================================
# Child Module: Network Security Group (NSG) with Granular Security Rules
# Author: Rahul Goyal (14+ Years Total IT | Senior DevOps Engineer)
# Zero-Trust Network Microsegmentation
# ============================================================================

variable "nsgs" {
  type        = map(any)
  description = "Map of Network Security Groups, rules, and subnet attachments"
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgs
  name                = each.value.name
  location            = each.value.location
  resource_group_name = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))

  dynamic "security_rule" {
    for_each = lookup(each.value, "security_rules", [])
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = lookup(security_rule.value, "source_port_range", "*")
      destination_port_range       = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges      = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
    }
  }

  tags = lookup(each.value, "tags", {})
}

# Subnet to NSG Binding
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each                  = { for k, v in var.nsgs : k => v if lookup(v, "subnet_id", null) != null }
  subnet_id                 = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
