output "demo_repository_url" {
  description = "URL of the repository managed by Terraform."
  value       = github_repository.demo.html_url
}
