terraform {
  required_version = "~> 1.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.72"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "github" {
  owner = var.organization_name
}
