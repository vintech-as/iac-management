variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "repository_configs" {
  description = "List of repository configurations"
  type = list(object({
    iac_repo_name         = string
    environment_role_arns = map(string)
  }))
}
