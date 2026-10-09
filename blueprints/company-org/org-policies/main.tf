resource "github_organization_ruleset" "default_branch" {
  name        = "org-default-branch-baseline"
  target      = "branch"
  enforcement = var.enforcement

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = sort(tolist(var.repository_name_patterns))
      exclude = sort(tolist(var.excluded_repository_names))
    }
  }

  rules {
    pull_request {
      required_approving_review_count = var.required_approvals
      dismiss_stale_reviews_on_push   = true
      allowed_merge_methods           = ["squash"]
    }
  }
}
