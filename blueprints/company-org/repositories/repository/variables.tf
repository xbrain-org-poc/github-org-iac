variable "organization" {
  description = "Actual company GitHub organization login. No default to prevent targeting the PoC org."
  type        = string
  nullable    = false
}

variable "repository" {
  description = "The GitHub repository managed by this Terraform root."
  type = object({
    name               = string
    description        = string
    visibility         = string
    has_issues         = optional(bool, true)
    has_wiki           = optional(bool, false)
    has_projects       = optional(bool, false)
    allow_squash_merge = optional(bool, true)
    allow_merge_commit = optional(bool, false)
    allow_rebase_merge = optional(bool, false)
  })
  nullable = false

  validation {
    condition = (
      contains(["private", "public", "internal"], var.repository.visibility) &&
      (var.repository.allow_squash_merge || var.repository.allow_merge_commit || var.repository.allow_rebase_merge)
    )
    error_message = "Repository needs a valid visibility and at least one merge method."
  }
}
