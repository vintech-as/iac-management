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
  }))

  default = {}
}
