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