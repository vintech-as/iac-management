variable "account_id" {
  description = "The name of the AWS account"
  type        = string
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "iac_repo_name" {
  description = "The name of the IaC repository for the project"
  type        = string
}