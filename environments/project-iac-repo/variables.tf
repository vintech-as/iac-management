variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "iac_repo_name" {
  description = "Name of the IaC repository"
  type        = string
}

variable "environment_role_arns" {
  description = "Map of environment names to their AWS role ARNs for deployment"
  type        = map(string)
  default     = {}
}