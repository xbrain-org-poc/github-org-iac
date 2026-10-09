# Separate root and child resources give Terraform an acyclic dependency graph.
resource "github_team" "root" {
  for_each = { for key, team in var.teams : key => team if team.parent_key == null }

  name                 = each.value.name
  description          = each.value.description
  privacy              = each.value.privacy
  notification_setting = each.value.notification_setting
}

resource "github_team" "child" {
  for_each = { for key, team in var.teams : key => team if team.parent_key != null }

  name                 = each.value.name
  description          = each.value.description
  privacy              = each.value.privacy
  notification_setting = each.value.notification_setting
  parent_team_id       = github_team.root[each.value.parent_key].id
}

locals {
  managed_teams = merge(github_team.root, github_team.child)
}
