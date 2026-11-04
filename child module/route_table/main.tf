# ============================================================================
# Child Module: Azure Route Table (User-Defined Routes / UDR)
# Author: Rahul Goyal (14+ Years Total IT | Senior DevOps Engineer)
# Zero-Trust Forced Tunneling via Central Azure Firewall
# ============================================================================

variable "route_tables" {
  type        = map(any)
  description = "Map of Route Tables, user-defined routes, and subnet attachments"
}

resource "azurerm_route_table" "rt" {
  for_each                      = var.route_tables
  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = lookup(each.value, "resource_group_name", lookup(each.value, "rg_name", null))
  bgp_route_propagation_enabled = lookup(each.value, "bgp_route_propagation_enabled", true)

  dynamic "route" {
    for_each = lookup(each.value, "routes", [])
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }

  tags = lookup(each.value, "tags", {})
}

# Subnet to Route Table Binding
resource "azurerm_subnet_route_table_association" "rt_assoc" {
  for_each       = { for k, v in var.route_tables : k => v if lookup(v, "subnet_id", null) != null }
  subnet_id      = each.value.subnet_id
  route_table_id = azurerm_route_table.rt[each.key].id
}
