variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "iac_repo_configs" {
  description = "Map of repository configurations"
  type = map(object({
    environment   = string
    iac_repo_name = string
    iac_role_arn  = string
  }))
}