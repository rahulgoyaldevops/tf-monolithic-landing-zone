# ============================================================================
# Enterprise Naming Conventions, Resource Tagging & Architecture Locals
# Designed by: Rahul Goyal (14+ Years Senior DevOps & Cloud Engineering)
# ============================================================================

locals {
  # Standardized CAF Naming Taxonomy: {resource_type}-{workload}-{environment}-{region_code}-{instance}
  name_prefix = "${var.project_name}-${var.environment}-${var.location_short}"

  # Mandatory FinOps & Governance Tags enforced across all child resources
  mandatory_tags = merge(
    var.custom_tags,
    {
      Environment       = upper(var.environment)
      ManagedBy         = "Terraform"
      EngineeringLead   = "Rahul Goyal"
      CostCenter        = var.cost_center
      DataSensitivity   = var.data_sensitivity
      ProvisionedDate   = formatdate("YYYY-MM-DD", timestamp())
      ComplianceScope   = "CIS-Azure-v2.0"
    }
  )

  # Centralized Subnet CIDR Calculation Matrix
  hub_vnet_address_space   = ["10.100.0.0/16"]
  spoke_prod_address_space = ["10.101.0.0/16"]
  spoke_uat_address_space  = ["10.102.0.0/16"]
}