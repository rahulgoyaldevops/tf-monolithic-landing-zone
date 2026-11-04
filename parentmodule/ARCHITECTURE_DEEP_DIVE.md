# 🏛️ Azure Landing Zone — Enterprise Architectural Deep Dive

> **Authored by:** Rahul Goyal — 14+ Years Total IT Background | Senior DevOps Engineer  
> **Target Audience:** Lead Cloud Engineers, DevOps Specialists, Platform Engineers

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

### B. Network Security Group (NSG) Microsegmentation
* Every subnet is strictly bound to an NSG enforcing:
  1. Priority 100: App Gateway / Hub Ingress allow rule for web tiers
  2. Priority 200: VirtualNetwork-to-VirtualNetwork intra-spoke communication
  3. Priority 300: Azure Load Balancer health probe allow rule
  4. Priority 4096: Explicit Default Deny All Inbound rule blocking any unrouted internet traffic

### C. DNS Resolution & Private Link Fabric
* Private Endpoints for Azure Key Vault, Storage Accounts, and Azure SQL link to centralized **Azure Private DNS Zones** in the Hub.
* Spokes are linked to the Hub DNS Zones with automatic PTR registration, ensuring complete on-premises to cloud hybrid DNS resolution.
* Hybrid multi-cloud and on-premises traffic resolves via **Azure DNS Private Resolver** with Inbound & Outbound forwarding rulesets.

### D. Terraform State Security & Concurrency Locking
* State is stored in a dedicated Geo-Redundant Storage Account (GRS) encrypted with Customer-Managed Keys (CMK).
* Blob Leases enforce state locking, preventing race conditions during concurrent pipeline executions.

---

## 3. Enterprise Architecture Governance & Hierarchy (CAF)

```
                            Tenant Root Group
                                    │
           ┌────────────────────────┴────────────────────────┐
           ▼                                                 ▼
      Platform MG                                      Landing Zones MG
    ┌──────┼──────┐                                   ┌──────┼──────┐
    ▼      ▼      ▼                                   ▼      ▼      ▼
  Mgmt  Connect Identity                            Online  Corp  Sandboxes
(Log Analytics) (Hub VNet / FW) (Entra Domain)     (Public) (Internal) (PoC)
```

1. **Management Group Structure:**
   - **Platform MG:** Enforces centralized observability (Log Analytics workspace), network perimeter (Hub Firewall, VPN/ExpressRoute), and identity infrastructure.
   - **Landing Zones MG:** Enforces guardrails such as mandatory CIS 2.0 Azure Policy initiatives, allowed VM SKUs, and data boundary tagging.
2. **Availability Zone Resiliency:**
   - Virtual machine and AKS compute nodes are explicitly distributed across availability zones (`zones = ["1", "2", "3"]`) guaranteeing 99.99% uptime SLA.
3. **Multi-Region Disaster Recovery:**
   - Active workloads deployed to primary region **Central India** (inc) with automated failover replication to paired region **South India** (ins), achieving RTO < 30m and RPO < 5m.

---
*Production Blueprint by [Rahul Goyal](https://github.com/rahulgoyaldevops)*
