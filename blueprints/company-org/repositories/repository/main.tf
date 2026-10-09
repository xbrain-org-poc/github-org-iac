module "repository" {
  source = "../../../../modules/repository"

  name               = var.repository.name
  description        = var.repository.description
  visibility         = var.repository.visibility
  has_issues         = var.repository.has_issues
  has_wiki           = var.repository.has_wiki
  has_projects       = var.repository.has_projects
  allow_squash_merge = var.repository.allow_squash_merge
  allow_merge_commit = var.repository.allow_merge_commit
  allow_rebase_merge = var.repository.allow_rebase_merge
}
