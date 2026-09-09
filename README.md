# Cloud Trio Challenge

A daily, one-topic-at-a-time comparison of **AWS vs Azure vs GCP** — plain English, one shared example per topic, and working Terraform for all three clouds.

## Structure

```
cloud-trio-challenge/
└── Day-N/
    ├── posts/          Blog post for that day (Medium-ready Markdown)
    ├── diagrams/        Hand-drawn style architecture diagrams for that day
    └── terraform/
        ├── aws/         Runnable Terraform for that day's AWS example
        ├── azure/       Runnable Terraform for that day's Azure example
        └── gcp/         Runnable Terraform for that day's GCP example
```

Each day gets its own folder, post, diagrams, and `main.tf` per cloud — all implementing the *same* example so the three clouds are directly comparable. See each `Day-N/README.md` for that day's specifics.

## Progress

| Day | Topic | Terraform |
|---|---|---|
| 1 | IAM vs Azure RBAC vs GCP IAM | ✅ aws · azure · gcp |
| 2 | Virtual Networking (VPC vs VNet vs VPC) | — |
| ... | | |
