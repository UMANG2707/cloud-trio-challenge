# Day 1: IAM vs Azure RBAC vs GCP IAM

Post: [posts/day-01-iam-vs-azure-vs-gcp.md](posts/day-01-iam-vs-azure-vs-gcp.md)

## Structure

```
Day-1/
├── posts/          Blog post (Medium-ready Markdown)
├── diagrams/        Hand-drawn style architecture diagrams
└── terraform/
    ├── aws/         Runnable Terraform for the AWS example
    ├── azure/       Runnable Terraform for the Azure example
    └── gcp/         Runnable Terraform for the GCP example
```

## Running the Terraform

Each cloud folder is self-contained. Pick one, `cd` into it, and:

```bash
terraform init
terraform plan
terraform apply
```

You'll need to fill in a few values first — a globally-unique bucket/storage-account name, your GCP project ID, and (for Azure) the path to an SSH public key. Each file has a comment marking exactly what to change.
