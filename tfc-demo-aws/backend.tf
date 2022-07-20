terraform {
  cloud {
    organization = "hc-emea-sentinel-demo"
    workspaces {
      tags = ["jit", "aws"]
    }
  }
}