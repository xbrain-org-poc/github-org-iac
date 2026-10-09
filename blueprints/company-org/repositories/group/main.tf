module "repository" {
  source   = "../../../../modules/repository"
  for_each = var.repositories

  name               = each.key
  description        = each.value.description
  visibility         = each.value.visibility
  has_issues         = each.value.has_issues
  has_wiki           = each.value.has_wiki
  has_projects       = each.value.has_projects
  allow_squash_merge = each.value.allow_squash_merge
  allow_merge_commit = each.value.allow_merge_commit
  allow_rebase_merge = each.value.allow_rebase_merge
}
