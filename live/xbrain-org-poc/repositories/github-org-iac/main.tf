resource "github_repository" "iac" {
  name        = "github-org-iac"
  description = "GitHub Organization IaC for xbrain-org-poc"
  visibility  = "public"
  auto_init   = false

  has_issues   = true
  has_projects = true
  has_wiki     = true

  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  lifecycle {
    prevent_destroy = true
  }
}
