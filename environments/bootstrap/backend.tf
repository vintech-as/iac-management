terraform {
  backend "s3" {
    bucket  = "vintech-terraform-state-eu-west-1"
    key     = "bootstrap/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}
