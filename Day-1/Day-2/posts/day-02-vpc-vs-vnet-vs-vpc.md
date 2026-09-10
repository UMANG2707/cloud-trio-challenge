# VPC vs VNet vs VPC — Quick Comparison

## 1. What each cloud calls it (current names, 2026)

| | AWS | Azure | GCP |
|---|---|---|---|
| Your private network | VPC (Virtual Private Cloud) | VNet (Virtual Network) | VPC Network |
| A slice of it | Subnet (zonal) | Subnet | Subnet (regional) |
| Traffic rule lives in | Route Table + Security Group | Network Security Group (NSG) | Firewall Rule (on the VPC) |
| Connect networks together | VPC Peering / Transit Gateway | VNet Peering / Virtual Network Manager | VPC Peering / Network Connectivity Center |

## 2. The one idea behind all three

- Every cloud does the same three things: draw a **network**, cut it into **subnets**, then decide **what traffic is let in or out**.
- **AWS** — the rule lives in a route table (where traffic can go) plus a security group (what's allowed).
- **Azure** — the rule lives in an NSG attached to the subnet (or the NIC).
- **GCP** — public vs private is a **route** decision (is there a path to the internet gateway, and does the instance have an external IP); a firewall rule on the VPC, matched by tag, only allows/blocks specific traffic on top of that.

## 3. VPC / VNet / VPC Network — the building blocks

Same job, different pieces. This is the part beginners mix up most, so match each row across the three columns:

| Component | AWS | Azure | GCP |
|---|---|---|---|
| The network | VPC — regional | VNet — regional | VPC Network — **global** (spans regions) |
| The slice | Subnet — zonal (1 AZ) | Subnet — regional | Subnet — regional |
| **What makes it public vs private** | **Route Table** entry — is there a route to the IGW or not | Public IP assigned + NSG allows inbound | **Route** to the internet gateway (exists by default) + does the instance have an external IP |
| Rule on the subnet | Network ACL — stateless, subnet-wide | **NSG** — stateful, attached to the subnet (or NIC) | *none* — subnets don't carry rules |
| Rule on the instance | Security Group — stateful, per instance | Same NSG, matched via **ASG** (Application Security Group) instead of an IP | **Firewall Rule** — stateful, lives on the VPC, matched by tag/service account |
| Group instances by role | Reference another Security Group | **ASG** — tag a VM "web" or "db" | Network tag or service account |
| Custom routing | **Route Table** per subnet | **Route Table (UDR)** — overrides the system route per subnet | **Routes** — global, live on the VPC; a default route to the internet gateway exists on every VPC automatically |
| Internet door | **Internet Gateway**, attached to the VPC | Public IP + the system default route | Default internet gateway — implicit, always there |
| Private subnet's way out | NAT Gateway | NAT Gateway / Azure Firewall | Cloud NAT |

One line per cloud to lock it in:
- **AWS** — the Route Table decides public vs private; two separate firewalls (NACL at the subnet, Security Group at the instance) decide what's allowed.
- **Azure** — one firewall (NSG), but you write its rules against ASGs, not IPs; Route Tables are optional overrides.
- **GCP** — the default Route to the internet gateway plus an external IP is what makes an instance reachable at all; the Firewall Rule (tag-matched) only decides what's allowed once it is.

## 4. Recent updates worth knowing (2025–2026)

- **AWS** — VPC Lattice: connect services across VPCs/accounts without hand-managing peering.
- **Azure** — Basic SKU public IPs were retired on 30 Sep 2025; every public IP must now be Standard SKU, which is secure-by-default (closed to inbound until an NSG explicitly allows it) — one more reason the NSG is doing real work now, not just Basic's old "open by default."
- **GCP** — Private Service Connect + Network Connectivity Center keep gaining connectivity patterns; check release notes, this area moves fast.

## 5. One example, implemented on all three clouds

**The task:** one network, split into a public subnet and a private subnet — public gets internet access, private does not.

Full runnable Terraform for each is in its own file:

- `aws-vpc-example.tf`
- `azure-vnet-example.tf`
- `gcp-vpc-example.tf`

Each one creates the network, both subnets, and just enough of a rule to prove the public/private split — nothing extra.

## 6. Cheat sheet: biggest beginner mistake per cloud

- **AWS** — assuming a subnet is "private" just because you didn't assign it a public IP; it's the route table that decides, not the IP.
- **Azure** — forgetting the NSG's default deny-all-inbound rule, then wondering why a "public" VM isn't reachable.
- **GCP** — assuming the firewall tag is what makes a VM "public"; it's the route to the internet gateway plus an external IP that does that — the tag only controls what the firewall lets through.

## 7. Remember this one line per cloud

- **AWS**: the route table decides where traffic can go; the security group decides what's allowed once it gets there.
- **Azure**: the NSG is the gate — no NSG rule, no traffic, no matter what subnet you're in.
- **GCP**: the route (plus an external IP) decides if traffic can get there at all; the firewall rule, matched by tag, decides what's allowed once it does.
