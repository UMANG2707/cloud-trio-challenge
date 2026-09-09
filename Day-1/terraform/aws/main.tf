############################################################
# Cloud Trio Challenge — Day 1: IAM
# AWS — let one EC2 instance read one S3 bucket, nothing else
############################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "my-app-data-bucket" # must be globally unique — change this
}

# --- The room: one S3 bucket ---
resource "aws_s3_bucket" "app_data" {
  bucket = var.bucket_name
}

# --- The badge: an IAM role only an EC2 instance can wear ---
resource "aws_iam_role" "app_role" {
  name = "app-read-one-bucket"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# --- The rule: read-only, and only for THIS bucket ---
resource "aws_iam_role_policy" "read_one_bucket" {
  name = "read-one-bucket"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        aws_s3_bucket.app_data.arn,
        "${aws_s3_bucket.app_data.arn}/*"
      ]
    }]
  })
}

# --- How EC2 actually wears the badge ---
resource "aws_iam_instance_profile" "app_profile" {
  name = "app-read-one-bucket"
  role = aws_iam_role.app_role.name
}

# Attach this to your instance:
#   resource "aws_instance" "app" {
#     ...
#     iam_instance_profile = aws_iam_instance_profile.app_profile.name
#   }

output "role_arn" {
  value = aws_iam_role.app_role.arn
}

output "bucket_name" {
  value = aws_s3_bucket.app_data.id
}
