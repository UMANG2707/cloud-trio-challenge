# Cloud Trio Challenge — Day 3: Database Services
############################################################
# AWS — one RDS PostgreSQL instance, closed by default
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

variable "db_username" {
  default = "appadmin"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

# --- The network: RDS needs a subnet group spanning at least 2 AZs ---
resource "aws_vpc" "db" {
  cidr_block = "10.1.0.0/16"
  tags       = { Name = "db-vpc" }
}

resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "db-subnet-a" }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "db-subnet-b" }
}

resource "aws_db_subnet_group" "app" {
  name       = "app-db-subnet-group"
  subnet_ids = [aws_subnet.db_a.id, aws_subnet.db_b.id]

  tags = { Name = "app-db-subnet-group" }
}

# --- What gates access: same idea as the Day 2 security group ---
# No ingress rule is defined here on purpose — the database is
# unreachable until you add one (e.g. from your own app's security group).
resource "aws_security_group" "db" {
  name   = "app-db-sg"
  vpc_id = aws_vpc.db.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-db-sg" }
}

# --- The instance ---
resource "aws_db_instance" "app" {
  identifier     = "app-postgres"
  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false

  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true

  tags = { Name = "app-postgres" }
}

output "db_endpoint" {
  value = aws_db_instance.app.endpoint
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}
