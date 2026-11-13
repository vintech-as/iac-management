variable "organization_name" {
  description = "GitHub organization name"
  type        = string
  default     = "vintech-as"
}

variable "iac_repo_configs" {
  description = "Repository configurations grouped by repository name"
  type = map(object({
    repo_name    = string
    environments = map(string) # Map of environment names to IAM role ARNs
  }))
  default = {}
}

# config/projects.tfvars, read directly so settings that need nothing computed by the
# earlier stages don't have to be passed through them. Only what this stage uses is
# read from it, and main checks its type.
variable "projects" {
  description = "The projects from config/projects.tfvars"
  type        = any
  default     = {}
}
