output "repository_urls" {
  value = { for name, repository in module.repository : name => repository.url }
}
