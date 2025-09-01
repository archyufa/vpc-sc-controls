# This Terraform configuration sets up a VPC Service Controls perimeter
# and an access level to allow Cloud Shell access for developers.

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Data source to get the organization ID
data "google_organization" "org" {
  domain = var.organization_domain
}

# Create the access policy
resource "google_access_context_manager_access_policy" "access_policy" {
  parent = data.google_organization.org.name
  title  = "Default Access Policy"
}

# Create the access level for Cloud Shell
resource "google_access_context_manager_access_level" "cloud_shell_access" {
  parent = google_access_context_manager_access_policy.access_policy.name
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/accessLevels/cloud_shell_access"
  title  = "Cloud Shell Access"

  basic {
    conditions {
      ip_subnetworks = ["209.85.152.0/22", "209.85.204.0/22", "216.58.192.0/19", "216.239.32.0/19", "35.191.0.0/16", "35.235.224.0/20", "64.233.160.0/19", "66.102.0.0/20", "66.249.80.0/20", "72.14.192.0/18", "74.125.0.0/16", "108.177.8.0/21", "172.217.0.0/16", "173.194.0.0/16"]
      members        = ["group:developers@mycompany.com"]
    }
  }
}

# Create the service perimeter
resource "google_access_context_manager_service_perimeter" "service_perimeter" {
  parent = google_access_context_manager_access_policy.access_policy.name
  name   = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/servicePerimeters/my_perimeter"
  title  = "My Perimeter"

  spec {
    restricted_services = ["storage.googleapis.com", "bigquery.googleapis.com", "compute.googleapis.com"]
    access_levels       = [google_access_context_manager_access_level.cloud_shell_access.name]
    resources           = ["projects/project-a", "projects/project-b", "projects/project-c"]
  }

  status {
    restricted_services = ["storage.googleapis.com", "bigquery.googleapis.com", "compute.googleapis.com"]
    access_levels       = [google_access_context_manager_access_level.cloud_shell_access.name]
  }

  # Set the perimeter to dry-run mode
  use_explicit_dry_run_spec = true
}

# Define variables
variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The region for the Google Cloud project."
  type        = string
  default     = "us-central1"
}

variable "organization_domain" {
  description = "The domain of the Google Cloud organization."
  type        = string
}