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

variable "require_up_to_date_branch" {
  description = "Whether a pull request must be up to date with the default branch before merging. Off by default: it holds back automerged dependency updates until they are rebased."
  type        = bool
  default     = false
}

variable "require_conversation_resolution" {
  description = "Whether every review conversation must be resolved before merging"
  type        = bool
  default     = false
}
