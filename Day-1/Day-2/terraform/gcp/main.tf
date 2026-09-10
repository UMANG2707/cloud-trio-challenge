# Cloud Trio Challenge — Day 2: Virtual Networking
############################################################
# GCP — one VPC Network, one public subnet, one private subnet
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

# --- The network: no IP range here, GCP VPCs are global by nature ---
resource "google_compute_network" "app" {
  name                    = "app-vpc"
  auto_create_subnetworks = false
}

# --- Public subnet ---
resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  network       = google_compute_network.app.id
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
}

# --- Private subnet ---
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  network       = google_compute_network.app.id
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
}

# --- The rule lives on the VPC, matched by tag — not on the subnet ---
resource "google_compute_firewall" "allow_public" {
  name    = "allow-public-tagged"
  network = google_compute_network.app.name

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"] # tighten this to your own IP in real use
  target_tags   = ["public"]
}

# No firewall rule targets "private" — default-deny ingress covers it.
# A VM tagged "private" gets no inbound access no matter which subnet it's in.

output "network_id" {
  value = google_compute_network.app.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public.id
}

output "private_subnet_id" {
  value = google_compute_subnetwork.private.id
}
