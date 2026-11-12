resource "github_repository_ruleset" "default_branch" {
  name        = "default-branch"
  repository  = var.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    dynamic "pull_request" {
      for_each = var.require_pull_request ? [1] : []
      content {
        # A required approval would block a single maintainer, who can't approve
        # their own pull request.
        required_approving_review_count   = 0
        required_review_thread_resolution = var.require_conversation_resolution
      }
    }

    dynamic "required_status_checks" {
      for_each = length(var.required_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = var.require_up_to_date_branch

        dynamic "required_check" {
          for_each = toset(var.required_checks)
          content {
            context = required_check.value
          }
        }
      }
    }
  }
}
