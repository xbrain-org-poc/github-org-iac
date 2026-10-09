resource "github_actions_repository_permissions" "demo" {
  repository      = github_repository.demo.name
  enabled         = true
  allowed_actions = "selected"

  allowed_actions_config {
    github_owned_allowed = true
    verified_allowed     = false
    patterns_allowed     = []
  }
}

resource "github_repository_environment" "dev" {
  repository  = github_repository.demo.name
  environment = "dev"
}

resource "github_actions_environment_variable" "dev_poc_environment" {
  repository    = github_repository.demo.name
  environment   = github_repository_environment.dev.environment
  variable_name = "POC_ENVIRONMENT"
  value         = "dev"
}
