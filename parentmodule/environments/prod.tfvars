# ============================================================================
# Production Environment Deployment Parameters
# Enterprise High-Availability Configuration
# ============================================================================

environment    = "prod"
project_name   = "core-platform"
location_short = "inc"
location       = "Central India"
cost_center    = "CC-INFRA-PROD-01"
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

virtual_machines = {
  vm1 = {
    name                = "vm-prod-app-01"
    rg_name             = "rg-core-platform-prod-inc-01"
    location            = "Central India"
    size                = "Standard_D4s_v5"
    admin_username      = "azureadmin"
    subnet_name         = "snet-app-prod-01"
    vnet_name           = "vnet-spoke-prod-inc-01"
    pip_name            = null
    enable_accelerated_networking = true
  }
}