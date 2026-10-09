resource "github_repository_ruleset" "default_branch" {
  name        = "protect-default-branch"
  repository  = github_repository.iac.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    pull_request {
      required_approving_review_count = 1
      dismiss_stale_reviews_on_push   = true
      allowed_merge_methods           = ["squash"]
    }
  }
}
