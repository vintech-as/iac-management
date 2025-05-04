terraform {
  required_version = "~> 1.11.4"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.organization_name
}
