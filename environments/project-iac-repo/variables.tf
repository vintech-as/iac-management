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
