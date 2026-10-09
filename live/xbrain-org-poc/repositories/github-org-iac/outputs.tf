output "repository_url" {
  description = "URL of the managed GitHub repository."
  value       = github_repository.iac.html_url
}
