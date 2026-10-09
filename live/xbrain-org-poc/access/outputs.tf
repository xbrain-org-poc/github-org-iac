output "teams" {
  description = "Managed team IDs, slugs and URLs for verification and import evidence."
  value = {
    for key, team in local.managed_teams : key => {
      id   = team.id
      slug = team.slug
      url  = "https://github.com/orgs/${var.github_org}/teams/${team.slug}"
    }
  }
}

output "team_memberships" {
  description = "Direct team memberships managed by this state; excludes inherited or unmanaged memberships."
  value = {
    for key, membership in github_team_membership.member : key => {
      team_id  = membership.team_id
      username = membership.username
      role     = membership.role
    }
  }
}
