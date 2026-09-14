# Cloud Trio Challenge — Day 3: Database Services
############################################################
# GCP — one Cloud SQL PostgreSQL instance, closed by default
############################################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Your GCP project ID"
}

variable "region" {
  default = "us-central1"
}

variable "db_password" {
  description = "Password for the app database user"
  type        = string
  sensitive   = true
}

# --- The instance ---
resource "google_sql_database_instance" "app" {
  name             = "app-postgres"
  database_version = "POSTGRES_16"
  region           = var.region

  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    # --- What gates access: same idea as an AWS security group or Azure firewall rule ---
    # No authorized network is added here on purpose — the instance has a
    # public IP, but nothing is allow-listed, so nothing can reach it yet.
    ip_configuration {
      ipv4_enabled = true

      # authorized_networks {
      #   name  = "office"
      #   value = "203.0.113.10/32" # tighten this to your own IP in real use
      # }
    }

    backup_configuration {
      enabled = true
    }
  }
}

resource "google_sql_database" "app" {
  name     = "appdb"
  instance = google_sql_database_instance.app.name
}

resource "google_sql_user" "app" {
  name     = "appadmin"
  instance = google_sql_database_instance.app.name
  password = var.db_password
}

output "instance_connection_name" {
  value = google_sql_database_instance.app.connection_name
}

output "public_ip_address" {
  value = google_sql_database_instance.app.public_ip_address
}
