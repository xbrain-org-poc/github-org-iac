output "repository_url" {
  description = "URL of the repository managed by Terraform."
  value       = github_repository.poc.html_url
}
