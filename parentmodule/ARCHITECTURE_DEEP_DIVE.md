# 🏛️ Azure Landing Zone — Enterprise Architectural Deep Dive

> **Authored by:** Rahul Goyal — 14+ Years Enterprise Cloud & Platform Engineering  
> **Target Audience:** Enterprise Architects, Cloud Security Officers, Lead DevOps Engineers

---

## 1. Topological Framework: Hub & Spoke Model

This implementation translates Microsoft's Cloud Adoption Framework (CAF) into a production-hardened, modular Terraform codebase.

```
                           +---------------------------+
                           |     ON-PREMISES DC        |
                           |   (192.168.0.0/16)        |
                           +-------------+-------------+
                                         |
                                ExpressRoute / S2S VPN
                                         |
+----------------------------------------v-----------------------------------------+
|                                HUB VNET (10.100.0.0/16)                          |
|                                                                                  |
|  +--------------------+   +-----------------------+   +-----------------------+  |
|  | GatewaySubnet      |   | AzureFirewallSubnet   |   | AzureBastionSubnet    |  |
|  | 10.100.0.0/24      |   | 10.100.1.0/24         |   | 10.100.2.0/24         |  |
|  +--------------------+   +-----------+-----------+   +-----------------------+  |
|                                       |                                          |
|                          Central Egress & Inspection                             |
+---------------------------------------+------------------------------------------+
                                        |
                 +----------------------+----------------------+
                 | VNet Peering                                | VNet Peering
                 | (Gateway Transit Enabled)                   | (Gateway Transit Enabled)
+----------------v-------------------------+ +-----------------v-------------------------+
|       PRODUCTION SPOKE (10.101.0.0/16)   | |         UAT SPOKE (10.102.0.0/16)       |
|                                          | |                                          |
| +--------------------------------------+ | | +--------------------------------------+ |
| | snet-app-prod (10.101.10.0/24)       | | | | snet-app-uat (10.102.10.0/24)        | |
| | UDR: 0.0.0.0/0 -> 10.100.1.4 (FW)    | | | | UDR: 0.0.0.0/0 -> 10.100.1.4 (FW)    | |
| +--------------------------------------+ | | +--------------------------------------+ |
| +--------------------------------------+ | | +--------------------------------------+ |
| | snet-db-prod (10.101.20.0/24)        | | | | snet-db-uat (10.102.20.0/24)         | |
| | NSG: Deny All Inbound except App     | | | | NSG: Deny All Inbound except App     | |
| +--------------------------------------+ | | +--------------------------------------+ |
+------------------------------------------+ +------------------------------------------+
```

---

## 2. Non-Negotiable Enterprise Design Decisions

### A. Forced Tunneling & Controlled Egress (Zero Bypass)
* All spoke subnets enforce a custom **User Defined Route (UDR)** sending `0.0.0.0/0` traffic to the Azure Firewall Private IP (`10.100.1.4`).
* Direct Internet access from workloads is mathematically disabled. No Public IPs are provisioned on application NICs.
* Inbound management traffic routes exclusively through Azure Bastion or PIM-enabled Just-In-Time (JIT) access policies.

### B. DNS Resolution & Private Link Fabric
* Private Endpoints for Azure Key Vault, Storage Accounts, and Azure SQL link to centralized **Azure Private DNS Zones** in the Hub.
* Spokes are linked to the Hub DNS Zones with automatic PTR registration, ensuring complete on-premises to cloud hybrid DNS resolution.

### C. Terraform State Security & Concurrency Locking
* State is stored in a dedicated Geo-Redundant Storage Account (GRS) encrypted with Customer-Managed Keys (CMK).
* Blob Leases enforce state locking, preventing race conditions during concurrent pipeline executions.

---
*Production Blueprint by [Rahul Goyal](https://github.com/rahulgoyaldevops)*