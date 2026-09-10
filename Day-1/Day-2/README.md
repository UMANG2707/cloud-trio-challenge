# Day 2 — VPC vs VNet vs VPC (Networking)

Post: [posts/day-02-vpc-vs-vnet-vs-vpc.md](posts/day-02-vpc-vs-vnet-vs-vpc.md)

## Structure

```
Day-2/
├── posts/
│   └── day-02-vpc-vs-vnet-vs-vpc.md
├── terraform/
│   ├── aws/
│   │   └── main.tf
│   ├── azure/
│   │   └── main.tf
│   └── gcp/
│       └── main.tf
└── README.md
```

## What's in this example

One network, split into a public subnet and a private subnet — public gets internet access, private does not — implemented identically on AWS, Azure, and GCP.

- `terraform/aws/main.tf` — VPC, public + private subnet, Internet Gateway, route table, security group
- `terraform/azure/main.tf` — VNet, public + private subnet, NSGs with security rules, subnet associations
- `terraform/gcp/main.tf` — VPC Network (custom mode), public + private subnet, tag-matched firewall rule
