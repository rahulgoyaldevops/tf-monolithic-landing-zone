<div align="center">

# 🏗️ Azure Monolithic Landing Zone — Terraform

[![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Enterprise-grade Azure Landing Zone built with modular Terraform — parent/child module pattern for scalable, reusable infrastructure.**

</div>

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     PARENT MODULE                            │
│                                                              │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐     │
│  │  Resource     │   │  Virtual     │   │   Subnet     │     │
│  │  Group        │──▶│  Network     │──▶│              │     │
│  │  Module       │   │  Module      │   │  Module      │     │
│  └──────────────┘   └──────────────┘   └──────┬───────┘     │
│                                                │             │
│  ┌──────────────┐                     ┌────────▼───────┐    │
│  │  Public IP   │────────────────────▶│  Linux VM      │    │
│  │  Module      │                     │  + NIC Module   │    │
│  └──────────────┘                     └────────────────┘    │
│                                                              │
│  🔐 Secrets from Azure Key Vault (VM admin password)        │
│  📦 Variable-driven: define infra in tfvars, not code       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 🧩 Module Structure

```
tf-monolithic-landing-zone/
├── parentmodule/
│   ├── main.tf              # Orchestrates all child modules
│   ├── variable.tf          # Input variables for all resources
│   ├── data.tf              # Key Vault secret lookups
│   ├── provider.tf          # AzureRM provider config
│   ├── .gitleaks.toml       # Secret scanning config
│   └── infracost.json       # Cost estimation output
│
└── child module/
    ├── resource_group/       # Azure Resource Group
    ├── virtual_network/      # VNet with configurable CIDR
    ├── subnet/               # Subnet with delegation support
    ├── pip/                  # Public IP allocation
    ├── network_interface/    # NIC with IP configuration
    └── azurerm_linux_virtual_machine/  # Linux VM with NIC
```

## 🚀 Key Design Decisions

| Decision | Rationale |
|:--|:--|
| **Parent/Child Module Pattern** | Enforces separation of concerns — each resource type is independently versionable and testable |
| **Variable-Driven Provisioning** | All infrastructure defined in `tfvars` — same modules deploy dev, UAT, and prod |
| **Key Vault Integration** | VM passwords fetched from Azure Key Vault at plan time — no secrets in code or state |
| **Dependency Chaining** | Explicit `depends_on` ensures correct resource creation order |
| **Gitleaks Integration** | Pre-commit secret scanning prevents credential leaks |
| **Infracost Integration** | Cost estimation before apply — no surprise bills |

## 💡 Usage

```bash
# Navigate to parent module
cd parentmodule

# Initialize Terraform
terraform init

# Preview changes with cost estimation
terraform plan -var-file="environments/dev.tfvars"

# Apply infrastructure
terraform apply -var-file="environments/dev.tfvars"
```

## 🔐 Security Best Practices

- ✅ No hardcoded secrets — Key Vault lookups via `data` blocks
- ✅ Gitleaks pre-commit scanning (`.gitleaks.toml`)
- ✅ State file excluded from git (`.gitignore`)
- ✅ Provider version pinning for reproducibility

## 🗺️ Roadmap

- [ ] Add Network Security Group (NSG) module
- [ ] Add Azure Firewall module for Hub-Spoke topology
- [ ] Add Azure Policy assignments module
- [ ] Add Management Group hierarchy module
- [ ] Remote state backend (Azure Storage Account)
- [ ] Terratest integration tests

---

<div align="center">

**Built by [Rahul Goyal](https://github.com/rahulgoyaldevops)** — Enterprise Cloud Architect | 14+ Years

</div>