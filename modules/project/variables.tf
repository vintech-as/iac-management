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
  type    = bool
  default = true
}

variable "code_repo_name" {
  type = string
}

variable "parent_ou_id" {
  type = string
}