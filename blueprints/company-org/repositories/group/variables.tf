variable "organization" {
  description = "Actual company GitHub organization login. No default to prevent targeting the PoC org."
  type        = string
  nullable    = false
}

variable "repositories" {
  description = "Repositories owned by this operational group. Map key is the GitHub repository name."
  type = map(object({
    description        = string
    visibility         = string
    has_issues         = optional(bool, true)
    has_wiki           = optional(bool, false)
    has_projects       = optional(bool, false)
    allow_squash_merge = optional(bool, true)
    allow_merge_commit = optional(bool, false)
    allow_rebase_merge = optional(bool, false)
  }))
  nullable = false

  validation {
    condition = alltrue([
      for name, repo in var.repositories :
      contains(["private", "public", "internal"], repo.visibility) &&
      (repo.allow_squash_merge || repo.allow_merge_commit || repo.allow_rebase_merge)
    ])
    error_message = "Every repository needs a valid visibility and at least one merge method."
  }
}
