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
