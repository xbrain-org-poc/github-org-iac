locals {
  memberships = merge({}, [
    for team_key, team in var.teams : {
      for username, role in team.members : "${team_key}:${username}" => {
        team_key = team_key
        username = username
        role     = role
      }
    }
  ]...)

  member_usernames = toset([for membership in local.memberships : membership.username])
}

# This is a READ-ONLY data source, not the Task A github_membership resource.
# Missing users fail the API lookup; pending invitees fail the postcondition.
data "github_membership" "existing" {
  for_each = local.member_usernames

  organization = var.github_org
  username     = each.value

  lifecycle {
    postcondition {
      condition     = self.state == "active"
      error_message = "${each.value} must already be an active member of ${var.github_org}. Accept the org invitation outside Task B, then make a fresh plan."
    }
  }
}

# Each resource owns only one direct membership; unlisted members are untouched.
resource "github_team_membership" "member" {
  for_each = local.memberships

  team_id  = local.managed_teams[each.value.team_key].id
  username = data.github_membership.existing[each.value.username].username
  role     = each.value.role

  lifecycle {
    precondition {
      condition = (
        data.github_membership.existing[each.value.username].role != "admin" ||
        each.value.role == "maintainer"
      )
      error_message = "${each.value.username} is an organization owner; configure their team role as maintainer."
    }
  }
}
