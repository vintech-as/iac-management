variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "organization_domain" {
  description = "GitHub organization domain"
  type        = string
  default     = "vintech.no"
}

variable "projects" {
  description = "Map of projects with their environments and repository information"
  type = map(object({
    environments    = list(string)
    code_repo_names = list(string)

    code_repo_required_checks = optional(map(list(string)), {})

    # Stricter merge rules, by code repository name. Both are off unless set.
    code_repo_branch_rules = optional(map(object({
      require_up_to_date_branch       = optional(bool, false)
      require_conversation_resolution = optional(bool, false)
    })), {})

    # Identity Center user names that get the Developer permission set in every environment account.
    developers = optional(list(string), [])
  }))

  default = {}
}

variable "notification_email" {
  description = "Email for budget alerts and alternate contacts"
  type        = string
  default     = "harald@vintech.no"
}

variable "contact_name" {
  description = "Name used for account alternate contacts"
  type        = string
  default     = "Harald Vinje"
}

variable "contact_phone" {
  description = "Phone number for account alternate contacts. Set via TF_VAR_contact_phone (GitHub secret SECURITY_CONTACT_PHONE); never commit it, this repo is public."
  type        = string
  sensitive   = true
}

variable "cost_anomaly_threshold_usd" {
  description = "Minimum total impact, in USD, for a cost anomaly to be emailed"
  type        = number
  default     = 10
}

variable "org_monthly_budget_usd" {
  description = "Monthly cost budget for the whole organization, in USD"
  type        = string
  default     = "150"
}

variable "cloudtrail_retention_days" {
  description = "Days to keep organization CloudTrail logs before expiry"
  type        = number
  default     = 365
}

variable "sandbox_budget_alerts_usd" {
  description = "Actual-spend email alert thresholds for the sandbox account, in USD"
  type        = list(number)
  default     = [30, 50]
}

variable "sandbox_budget_hard_stop_usd" {
  description = "Monthly sandbox spend (USD) at which the sandbox-freeze SCP is attached automatically"
  type        = string
  default     = "100"
}
