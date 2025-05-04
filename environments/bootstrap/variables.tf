variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "bootstrap_configs" {
  description = "List of bootstrap configurations"
  type = list(object({
    iac_repo_name              = string
    environment_to_account_ids = map(string)
  }))
}
