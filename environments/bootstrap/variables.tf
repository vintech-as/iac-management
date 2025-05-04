variable "account_id" {
  description = "The ID of the AWS account to bootstrap"
  type        = string
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "iac_repo_name" {
  description = "The name of the IaC repository for the project. Used to create the IAM role for GitHub Actions."
  type        = string
}