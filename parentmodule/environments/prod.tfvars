# ============================================================================
# Production Environment Deployment Parameters
# Enterprise High-Availability Configuration
# ============================================================================

environment      = "prod"
project_name     = "core-platform"
location_short   = "inc"
location         = "Central India"
cost_center      = "CC-INFRA-PROD-01"
data_sensitivity = "Confidential"

rgs = {
  rg1 = {
    name     = "rg-core-platform-prod-inc-01"
    location = "Central India"
  }
}

vnet = {
  vnet1 = {
    name          = "vnet-spoke-prod-inc-01"
    location      = "Central India"
    rg_name       = "rg-core-platform-prod-inc-01"
    address_space = ["10.101.0.0/16"]
  }
}

subnet = {
  subnet_app = {
    name             = "snet-app-prod-01"
    rg_name          = "rg-core-platform-prod-inc-01"
    vnet_name        = "vnet-spoke-prod-inc-01"
    address_prefixes = ["10.101.10.0/24"]
  }
  subnet_db = {
    name             = "snet-db-prod-01"
    rg_name          = "rg-core-platform-prod-inc-01"
    vnet_name        = "vnet-spoke-prod-inc-01"
    address_prefixes = ["10.101.20.0/24"]
  }
}

pip = {
  pip1 = {
    name              = "pip-natgw-prod-inc-01"
    rg_name           = "rg-core-platform-prod-inc-01"
    location          = "Central India"
    allocation_method = "Static"
    sku               = "Standard"
  }
}

# Network Security Groups (Granular Microsegmentation & Default Deny)
nsgs = {
  nsg_app = {
    name       = "nsg-app-prod-inc-01"
    location   = "Central India"
    rg_name    = "rg-core-platform-prod-inc-01"
    subnet_key = "subnet_app"
    security_rules = [
      {
        name                       = "Allow-AppGw-Inbound-HTTP-HTTPS"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443", "8080"]
        source_address_prefix      = "10.100.0.0/16" # Hub VNet App Gateway tier
        destination_address_prefix = "10.101.10.0/24"
      },
      {
        name                       = "Allow-Intra-VNet"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "Allow-Azure-LoadBalancer-Probe"
        priority                   = 300
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-All-Inbound-Internet"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    ]
  }
}

# Route Tables (Zero-Trust Forced Tunneling to Hub Azure Firewall)
route_tables = {
  rt_app = {
    name                          = "rt-spoke-prod-inc-01"
    location                      = "Central India"
    rg_name                       = "rg-core-platform-prod-inc-01"
    subnet_key                    = "subnet_app"
    bgp_route_propagation_enabled = true
    routes = [
      {
        name                   = "udr-default-to-hub-firewall"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = "10.100.1.4" # Central Azure Firewall Private IP
      }
    ]
  }
}

virtual_machines = {
  vm1 = {
    name                          = "vm-prod-app-01"
    rg_name                       = "rg-core-platform-prod-inc-01"
    location                      = "Central India"
    zone                          = "1"
    size                          = "Standard_D4s_v5"
    admin_username                = "azureadmin"
    subnet_name                   = "snet-app-prod-01"
    vnet_name                     = "vnet-spoke-prod-inc-01"
    pip_name                      = null
    enable_accelerated_networking = true
  }
}
