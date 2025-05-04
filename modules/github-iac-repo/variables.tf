variable "organization_name" {
  description = "GitHub organization name"
  type        = string
}

variable "iac_repo_name" {
  description = "Name of the IaC repository"
  type        = string
}

variable "environment_role_arns" {
  description = "Map of environment names to role ARNs"
  type        = map(string)
}
