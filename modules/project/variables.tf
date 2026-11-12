variable "project_name" {
  type = string
}

variable "organization_domain" {
  type = string
}

variable "environments" {
  type = list(string)
}

variable "use_code_repo" {
  description = "Whether to create code repositories"
  type        = bool
  default     = true
}

variable "code_repo_names" {
  description = "List of names for the code repositories"
  type        = list(string)
}

variable "code_repo_required_checks" {
  description = "Status checks that must pass before merging, by code repository name"
  type        = map(list(string))
  default     = {}
}

variable "code_repo_branch_rules" {
  description = "Stricter merge rules, by code repository name"
  type = map(object({
    require_up_to_date_branch       = optional(bool, false)
    require_conversation_resolution = optional(bool, false)
  }))
  default = {}
}

variable "parent_ou_id" {
  type = string
}
variable "sso_instance_arn" {
  description = "IAM Identity Center instance ARN"
  type        = string
}

variable "admin_permission_set_arn" {
  description = "Permission set assigned to the admin group in every environment account"
  type        = string
}

variable "admin_group_id" {
  description = "Identity Center group that gets admin access to every environment account"
  type        = string
}

variable "identity_store_id" {
  description = "Identity Center identity store, where the project's developer group is created"
  type        = string
}

variable "developer_permission_set_arn" {
  description = "Permission set assigned to the project's developer group in every environment account"
  type        = string
}

variable "developer_users" {
  description = "Identity Center user IDs by user name, for the project's developer group. Without any, no group is created."
  type        = map(string)
  default     = {}
}
