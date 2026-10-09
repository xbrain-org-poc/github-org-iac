variable "organization" {
  description = "GitHub organization owning the ruleset."
  type        = string
  default     = "xbrain-org-poc"
}

variable "target_repositories" {
  description = "Repository names targeted by the organization ruleset."
  type        = set(string)
  default     = ["github-org-iac", "repository-demo"]

  validation {
    condition     = length(var.target_repositories) > 0
    error_message = "At least one repository must be targeted."
  }
}
