# Day 3 — Managed Database Services (AWS vs Azure vs GCP)

Post: [posts/day-03-database-services.md](posts/day-03-database-services.md)

## Structure

```
Day-3/
├── posts/
│   └── day-03-database-services.md
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

One managed PostgreSQL instance, reachable only from an explicitly allow-listed network — closed by default, implemented identically on AWS, Azure, and GCP.

- `terraform/aws/main.tf` — RDS for PostgreSQL, its own VPC + 2 subnets (RDS requires 2 AZs for the subnet group), a security group with no inbound rule by default
- `terraform/azure/main.tf` — Flexible Server for PostgreSQL, public access mode with no firewall rule by default
- `terraform/gcp/main.tf` — Cloud SQL for PostgreSQL, public IP with no authorized network by default
