# Managed Database Services: AWS vs Azure vs GCP

## 1. What each cloud calls it (current names, 2026)

| | AWS | Azure | GCP |
|---|---|---|---|
| Managed relational DB | RDS (Relational Database Service) | Azure Database for PostgreSQL/MySQL: **Flexible Server** | Cloud SQL |
| High-throughput/cloud-native variant | Aurora | Azure Cosmos DB for PostgreSQL (Citus) | AlloyDB |
| A single deployable unit | DB Instance | Flexible Server | Instance |
| Access control | Security Group + IAM auth | Firewall rule / VNet integration + Entra auth | Authorized network / Private IP + Cloud SQL IAM auth |

## 2. The one idea behind all three

- Every cloud does the same three things: give you a **managed engine** (Postgres/MySQL/etc. patched and backed up for you), let you pick **compute + storage** independently, then decide **who can reach it**.
- **AWS**: the instance sits inside your VPC; a security group (same primitive as Day 2) is the gate, plus an optional subnet group controls which AZs it can live in.
- **Azure**: a Flexible Server is reachable through either public access (gated by firewall rules) or private access (delegated subnet inside your VNet); you choose the mode at creation time.
- **GCP**: the instance gets a public IP, a private IP, or both; if public, an authorized-networks list decides who can connect, same "allow list" idea as an AWS security group or Azure firewall rule.

## 3. Building blocks: the part beginners mix up most

| Component | AWS RDS | Azure Flexible Server | GCP Cloud SQL |
|---|---|---|---|
| The deployable unit | DB Instance | Flexible Server | Instance |
| Compute size | Instance class (e.g. `db.t3.micro`) | SKU name (e.g. `B_Standard_B1ms`) | Tier (e.g. `db-f1-micro`) |
| Storage | `allocated_storage` (GiB), can autoscale | `storage_mb`, scales up only | Part of `settings`, autoscale optional |
| Networking home | VPC subnet group (2+ AZs required) | Public access **or** delegated VNet subnet | Public IP, Private IP (VPC peering), or both |
| **What gates access** | Security Group attached to the instance | Firewall rule (public mode) or NSG on the delegated subnet (private mode) | Authorized network entry (public) or VPC peering (private) |
| High availability | Multi-AZ (standby replica, automatic failover) | Zone-redundant HA (paired zone) | Regional (HA) configuration across zones |
| Backups | Automated backups + snapshots, point-in-time restore | Automated backups, point-in-time restore | Automated backups, point-in-time recovery |
| Password-less auth | IAM database authentication | Microsoft Entra authentication | Cloud SQL IAM database authentication |
| Safer major upgrades | Blue/Green Deployments (clone, test, switch over) | In-place major version upgrade (rolling) | In-place major version upgrade |

One line per cloud to lock it in:
- **AWS**: the security group (same object type as Day 2) is what decides who can reach the instance; the subnet group only decides where it physically lives.
- **Azure**: you pick public-with-firewall-rules or private-with-VNet-delegation at creation time; you can't add private access after the fact without recreating.
- **GCP**: public IP + authorized networks is the "just allow my IP" mode; private IP (via VPC peering) is the production mode, same allow-list idea either way.

## 4. Recent updates worth knowing (2025 to 2026)

- **AWS**: RDS Blue/Green Deployments now switch over in **under 5 seconds** (as of early 2026), making major-version upgrades and schema changes far safer to run in production.
- **Azure**: Azure Database for PostgreSQL/MySQL **Single Server was retired on 28 March 2025**. Flexible Server is now the only deployment option; if you still see "Single Server" in an old tutorial, it no longer exists.
- **GCP**: Cloud SQL for PostgreSQL **16 and newer now defaults to the Enterprise Plus edition** (more memory, faster storage) unless you explicitly request the standard Enterprise edition.

## 5. One example, implemented on all three clouds

**The task:** one managed PostgreSQL instance, reachable only from an explicitly allow-listed network (not the whole internet), the minimum viable "locked down by default" setup.

Full runnable Terraform for each is in its own file:

- `aws-rds-example.tf`: RDS for PostgreSQL, its own small VPC + 2 subnets (RDS requires 2 AZs for the subnet group), a security group with **no inbound rule by default** (add your own CIDR to open it).
- `azure-postgres-example.tf`: Flexible Server for PostgreSQL, public access mode with a firewall rule you fill in; no rule, no traffic, same idea as the Day 2 NSG.
- `gcp-cloudsql-example.tf`: Cloud SQL for PostgreSQL, public IP with an `authorized_networks` list you fill in; empty list ships closed.

Each one creates the instance, a database, and a user; nothing extra, and nothing open by default.

## 6. Cheat sheet: biggest beginner mistake per cloud

- **AWS**: forgetting the DB subnet group needs subnets in **at least two** Availability Zones, even for a single-AZ instance; Terraform will fail to create it with only one.
- **Azure**: trying to switch a public-access Flexible Server to private (VNet-delegated) after creation; it can't be done in place, so you plan the access mode up front.
- **GCP**: assuming a public IP alone makes the instance reachable; with an empty `authorized_networks` list, nothing gets in, same as Day 2's "the route isn't the whole story."

## 7. Remember this one line per cloud

- **AWS**: the instance lives in your VPC, so the same security-group model from Day 2 controls access; nothing new to learn.
- **Azure**: pick public-with-firewall-rules or private-with-VNet-delegation at creation time; that choice isn't reversible in place.
- **GCP**: a public IP is just an address; the authorized-networks list is what actually opens the door.
