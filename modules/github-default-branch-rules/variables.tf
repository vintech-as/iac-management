variable "repository" {
  description = "Name of the repository to protect"
  type        = string
}

variable "require_pull_request" {
  description = "Whether changes to the default branch must go through a pull request"
  type        = bool
  default     = true
}

variable "required_checks" {
  description = "Names of the status checks that must pass before merging to the default branch"
  type        = list(string)
  default     = []
}
