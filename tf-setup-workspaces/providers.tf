
terraform {
  required_providers {
    tfe = {
      version = "~> 0.33.0"
    }
    tls = {
      version = "~> 3.4.0"
    }
    aws = {
      version = "~> 4.22.0"
    }
    google-beta = {
      version = "~> 4.29.0"
    }
    google = {
      version = "~> 4.29.0"
    }
  }
}

provider "tfe" {
}

provider "aws" {
  region = "eu-west-1"
}

provider "google-beta" {
}
provider "google" {
}