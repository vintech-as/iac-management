terraform {
  backend "s3" {
    bucket  = "vintech-terraform-state-eu-west-1"
    key     = "iac-repos/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}