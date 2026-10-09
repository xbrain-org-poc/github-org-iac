variable "github_org" {
  description = "Existing sandbox GitHub organization login, not a personal account or URL."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]*$", var.github_org))
    error_message = "github_org must be an organization login without spaces or a URL."
  }
}

variable "teams" {
  description = "PoC teams keyed by stable local names. parent_key may reference a root team in this map (one nesting level). members maps lowercase existing org logins to member or maintainer."
  type = map(object({
    name                 = string
    description          = optional(string, "Sandbox team managed by the Task B Terraform PoC")
    privacy              = optional(string, "closed")
    notification_setting = optional(string, "notifications_enabled")
    parent_key           = optional(string)
    members              = optional(map(string), {})
  }))
  nullable = false

  validation {
    condition = alltrue([
      for key, team in var.teams :
      can(regex("^[a-z0-9][a-z0-9_-]*$", key)) && try(trimspace(team.name) != "", false)
    ])
    error_message = "Use nonempty team names and stable lowercase keys containing only letters, digits, underscores or hyphens."
  }

  validation {
    condition     = length(distinct([for team in var.teams : try(lower(trimspace(team.name)), "")])) == length(var.teams)
    error_message = "Team names must be unique, ignoring case and surrounding spaces."
  }

  validation {
    condition = alltrue([
      for team in var.teams :
      contains(["closed", "secret"], team.privacy) &&
      contains(["notifications_enabled", "notifications_disabled"], team.notification_setting)
    ])
    error_message = "privacy must be closed or secret; notification_setting must be notifications_enabled or notifications_disabled."
  }

  validation {
    condition = alltrue(flatten([
      for team in var.teams : [
        for username, role in team.members :
        can(regex("^[a-z0-9]([a-z0-9-]{0,37}[a-z0-9])?$", username)) &&
        contains(["member", "maintainer"], role)
      ]
    ]))
    error_message = "Member keys must be lowercase GitHub logins; team roles must be member or maintainer."
  }

  validation {
    condition = alltrue([
      for key, team in var.teams : team.parent_key == null ? true : try(
        team.parent_key != key &&
        var.teams[team.parent_key].parent_key == null &&
        var.teams[team.parent_key].privacy == "closed" &&
        team.privacy == "closed",
        false
      )
    ])
    error_message = "A child must reference a different existing root team; both must be closed. Only one nesting level is supported in this PoC."
  }
}
