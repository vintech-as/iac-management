variable "account_id" {
  description = "The name of the AWS account"
  type        = string
}

variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "organization_id" {
  description = "Numeric GitHub organization ID, used in ID-based OIDC subjects"
  type        = string
  default     = "209782940"
}

variable "iac_repo_name" {
  description = "The name of the IaC repository for the project"
  type        = string
}

variable "environment" {
  description = "The name of the AWS environment"
  type        = string
}
