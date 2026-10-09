# One organization ruleset can target multiple repositories on a supported plan.
resource "github_organization_ruleset" "default_branch" {
  name        = "poc-org-protect-default-branch"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = sort(tolist(var.target_repositories))
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
