############################################################
# Cloud Trio Challenge — Day 1: IAM
# GCP — let one Compute VM read one Storage Bucket, nothing else
############################################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
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

variable "zone" {
  default = "us-central1-a"
}

variable "bucket_name" {
  default = "my-app-data-bucket" # base name — a random suffix is appended to keep it globally unique
}

# Bucket names must be globally unique across all GCP projects,
# so a random suffix is appended automatically instead of requiring a manual edit.
resource "random_id" "suffix" {
  byte_length = 4
}

# --- The room: one Storage Bucket ---
resource "google_storage_bucket" "app_data" {
  name                        = "${var.bucket_name}-${random_id.suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# --- The badge: a service account, attached to the VM ---
resource "google_service_account" "app_sa" {
  account_id   = "app-read-one-bucket"
  display_name = "App badge — read one bucket"
}

resource "google_compute_instance" "app_vm" {
  name         = "app-vm"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {} # gives it a public IP; drop this block for private-only
  }

  service_account {
    email  = google_service_account.app_sa.email
    scopes = ["cloud-platform"]
  }
}

# --- The rule: read-only, added directly to the BUCKET's own guest
# list — not to the project, and not to the badge ---
resource "google_storage_bucket_iam_member" "read_one_bucket" {
  bucket = google_storage_bucket.app_data.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.app_sa.email}"
}

output "service_account_email" {
  value = google_service_account.app_sa.email
}

output "bucket_name" {
  value = google_storage_bucket.app_data.name
}
