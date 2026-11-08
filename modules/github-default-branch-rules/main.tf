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
        required_approving_review_count = 0
      }
    }
  }
}
