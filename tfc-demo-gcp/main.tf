terraform {
  cloud {
    organization = "hc-emea-sentinel-demo"
    workspaces {
      tags = ["jit", "gcp"]
    }
  }
  
  required_providers {
    google = {
      version = "~> 4.29.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "your GCP project ID"
}

provider "google" {
  region = "us-west1"

}

resource "google_compute_instance" "vm_instance" {
  project      = var.project_id
  zone         = "us-west1-a"
  name         = "terraform-test-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
