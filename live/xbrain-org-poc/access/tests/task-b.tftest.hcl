# Every run is a mocked plan: these tests do not authenticate to or mutate GitHub.
mock_provider "github" {
  mock_data "github_membership" {
    defaults = {
      state = "active"
      role  = "member"
    }
  }
}

variables {
  github_org = "task-b-sandbox"
  teams = {
    platform = {
      name    = "poc-platform"
      members = { alice = "member" }
    }
  }
}

run "active_member_is_accepted" {
  command = plan

  assert {
    condition     = github_team_membership.member["platform:alice"].role == "member"
    error_message = "An existing active organization member should retain the configured team role."
  }
}

run "pending_invitation_is_rejected" {
  command = plan

  override_data {
    target = data.github_membership.existing["alice"]
    values = {
      state = "pending"
      role  = "member"
    }
  }

  expect_failures = [data.github_membership.existing]
}

run "owner_cannot_be_a_regular_team_member" {
  command = plan

  override_data {
    target = data.github_membership.existing["alice"]
    values = {
      state = "active"
      role  = "admin"
    }
  }

  expect_failures = [github_team_membership.member]
}

run "owner_can_be_a_team_maintainer" {
  command = plan

  variables {
    teams = {
      platform = {
        name    = "poc-platform"
        members = { alice = "maintainer" }
      }
    }
  }

  override_data {
    target = data.github_membership.existing["alice"]
    values = {
      state = "active"
      role  = "admin"
    }
  }

  assert {
    condition     = github_team_membership.member["platform:alice"].role == "maintainer"
    error_message = "An organization owner must be accepted when configured as a team maintainer."
  }
}

run "shared_username_has_distinct_memberships_and_one_lookup" {
  command = plan

  variables {
    teams = {
      platform = {
        name    = "poc-platform"
        members = { alice = "maintainer" }
      }
      service = {
        name       = "poc-service"
        parent_key = "platform"
        members    = { alice = "member" }
      }
    }
  }

  assert {
    condition     = toset(keys(github_team_membership.member)) == toset(["platform:alice", "service:alice"])
    error_message = "Each team/login pair must have its own stable Terraform address."
  }

  assert {
    condition     = toset(keys(data.github_membership.existing)) == toset(["alice"])
    error_message = "A shared username must be checked only once at organization scope."
  }

  assert {
    condition     = toset(keys(github_team.root)) == toset(["platform"]) && toset(keys(github_team.child)) == toset(["service"])
    error_message = "A valid hierarchy must put the parent and child in their respective dependency layers."
  }
}

run "invalid_team_role_is_rejected" {
  command = plan

  variables {
    teams = {
      platform = {
        name    = "poc-platform"
        members = { alice = "admin" }
      }
    }
  }

  expect_failures = [var.teams]
}

run "invalid_privacy_is_rejected" {
  command = plan

  variables {
    teams = {
      platform = {
        name    = "poc-platform"
        privacy = "public"
      }
    }
  }

  expect_failures = [var.teams]
}

run "secret_parent_is_rejected" {
  command = plan

  variables {
    teams = {
      platform = {
        name    = "poc-platform"
        privacy = "secret"
      }
      service = {
        name       = "poc-service"
        parent_key = "platform"
      }
    }
  }

  expect_failures = [var.teams]
}

run "secret_child_is_rejected" {
  command = plan

  variables {
    teams = {
      platform = { name = "poc-platform" }
      service = {
        name       = "poc-service"
        privacy    = "secret"
        parent_key = "platform"
      }
    }
  }

  expect_failures = [var.teams]
}

run "missing_parent_is_rejected" {
  command = plan

  variables {
    teams = {
      service = {
        name       = "poc-service"
        parent_key = "missing"
      }
    }
  }

  expect_failures = [var.teams]
}

run "deeper_nesting_is_rejected" {
  command = plan

  variables {
    teams = {
      platform = { name = "poc-platform" }
      service = {
        name       = "poc-service"
        parent_key = "platform"
      }
      component = {
        name       = "poc-component"
        parent_key = "service"
      }
    }
  }

  expect_failures = [var.teams]
}

run "empty_configuration_is_valid_for_reviewed_cleanup" {
  command = plan

  variables {
    teams = {}
  }

  assert {
    condition     = length(github_team.root) == 0 && length(github_team.child) == 0 && length(github_team_membership.member) == 0 && length(data.github_membership.existing) == 0
    error_message = "An empty configuration must be valid and leave no desired teams, memberships, or organization reads."
  }
}
