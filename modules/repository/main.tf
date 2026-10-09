resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility
  auto_init   = true

  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  allow_squash_merge     = var.allow_squash_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_rebase_merge     = var.allow_rebase_merge
  delete_branch_on_merge = true

  lifecycle {
    prevent_destroy = true
  }
}
