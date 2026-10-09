output "organization_ruleset_id" {
  description = "ID of the organization ruleset after it is applied."
  value       = github_organization_ruleset.default_branch.ruleset_id
}
