# 🏛️ Azure Landing Zone — Enterprise Architectural Deep Dive

> **Authored by:** Rahul Goyal — 14+ Years Total IT Background | Senior Azure DevOps Engineer  
> **Target Audience:** Cloud Engineers, DevOps Specialists, Enterprise & Platform Architects

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

## 3. Microsoft CAF Enterprise-Scale Management Group Hierarchy

The Management Group hierarchy follows the official **Microsoft Cloud Adoption Framework (CAF) Enterprise-Scale Landing Zone** architecture pattern:

```
                                    Tenant Root Group (/)
                                              │
                              Intermediate Root Management Group
                              (mg-enterprise / "Enterprise Root")
                                              │
        ┌───────────────────────┬─────────────┴─────────────┬────────────────────────┐
        ▼                       ▼                           ▼                        ▼
    [Platform]            [Landing Zones]              [Sandboxes]            [Decommissioned]
  (mg-platform)          (mg-landing-zones)          (mg-sandboxes)         (mg-decommissioned)
        │                       │                           │                        │
  ┌─────┼─────┐           ┌─────┴─────┐             ┌───────┴──────┐         ┌───────┴──────┐
  ▼     ▼     ▼           ▼           ▼             ▼              ▼         ▼              ▼
Mgmt  Conn  Identity    Corp        Online       Sandbox Subs  Dev Lab Subs Expired Subs Retiring Subs
  │     │     │           │           │          (Isolated R&D)          (Zero Spend)
  │     │     │           │           │
  │     │     │           │           └─ Public Web Apps (Front Door / WAF Ingress)
  │     │     │           └─ Internal Line-of-Business Workloads (19 Migrated Apps)
  │     │     └─ Identity Sub (Entra Domain Services / Domain Controllers / IaaS Key Vaults)
  │     └─ Connectivity Sub (Hub VNet / Azure Firewall / ExpressRoute / DNS Private Resolver)
  └─ Management Sub (Log Analytics Workspace / Sentinel / Automation / Azure Monitor)
```

### Detailed Structural Mapping According to Microsoft CAF

| Management Group | Purpose in CAF | Target Subscriptions | Key Azure Policies Applied |
| :--- | :--- | :--- | :--- |
| **Intermediate Root** (`mg-enterprise`) | Anchors global enterprise governance without modifying root tenant permissions. | Top-level container | CIS Microsoft Azure Foundations Benchmark, Tagging enforcement |
| **Platform** (`mg-platform`) | Parent container for centralized shared core IT operations and connectivity. | Platform tier | Audit resource locations, Deny non-approved regions |
| ↳ **Management** (`mg-platform-mgmt`) | Centralized observability, log ingestion, and incident telemetry. | Management Subscription | Mandatory diagnostic settings export to central Log Analytics |
| ↳ **Connectivity** (`mg-platform-conn`) | Hybrid routing, network hub perimeter, and centralized egress inspection. | Connectivity Subscription | Enforce Azure Firewall policy, DDoS protection, Azure DNS Private Resolver |
| ↳ **Identity** (`mg-platform-identity`) | Identity & access services (Active Directory / Entra ID sync). | Identity Subscription | Restrict public IPs on NICs, Enforce disk encryption |
| **Landing Zones** (`mg-landing-zones`) | Parent container for business workload subscriptions running application tiers. | Application workloads | Inherits enterprise guardrails, enforces secure storage (HTTPS only) |
| ↳ **Corp** (`mg-lz-corp`) | Connected workloads with private line-of-business connectivity back to on-prem via Hub. | 19 Enterprise Apps, AKS Internal | **Deny Public IP creation on NICs**, Enforce Subnet NSG associations |
| ↳ **Online** (`mg-lz-online`) | Internet-facing apps utilizing perimeter services (Front Door / App Gateway WAF). | E-commerce, Public APIs | Mandatory WAF enablement, TLS 1.2+ minimum cipher suites |
| **Sandboxes** (`mg-sandboxes`) | Isolated playground subscriptions for developer experimentation and PoCs. | Innovation & R&D | **Deny VNet Peering to Hub/Corp**, Spending budget triggers, Auto-shutdown |
| **Decommissioned** (`mg-decommissioned`) | Quarantine holding zone for subscriptions being cancelled or migrated away. | Deprecated / Replaced | **Deny resource creation (`*`)**, Quota reduction to zero |

---

## 4. Availability Zone & Multi-Region Resiliency

1. **Availability Zone Pinning:**
   - Compute VMs and AKS node pools are distributed across Availability Zones (`zones = ["1", "2", "3"]`), guaranteeing 99.99% infrastructure uptime SLA.
2. **Paired Multi-Region Disaster Recovery:**
   - Active workloads deployed to primary region **Central India (inc)** with automated replication to paired region **South India (ins)**:
   - **RTO < 30 minutes** (Front Door Anycast routing + AKS node pool autoscale).
   - **RPO < 5 minutes** (Azure SQL Auto-Failover Group + geo-redundant storage snapshot replication).

---
*Production Blueprint by [Rahul Goyal](https://github.com/rahulgoyaldevops)*
