variable "repository" {
  description = "Name of the repository to protect"
  type        = string
}

variable "require_pull_request" {
  description = "Whether changes to the default branch must go through a pull request"
  type        = bool
  default     = true
}
