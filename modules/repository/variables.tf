variable "name" {
  description = "Repository name within the organization."
  type        = string
}

variable "description" {
  description = "Short repository description."
  type        = string
}

variable "visibility" {
  description = "Repository visibility, subject to organization policy and plan."
  type        = string

  validation {
    condition     = contains(["private", "public", "internal"], var.visibility)
    error_message = "visibility must be private, public, or internal."
  }
}

variable "has_issues" {
  type    = bool
  default = true
}

variable "has_wiki" {
  type    = bool
  default = false
}

variable "has_projects" {
  type    = bool
  default = false
}

variable "allow_squash_merge" {
  type    = bool
  default = true
}

variable "allow_merge_commit" {
  type    = bool
  default = false
}

variable "allow_rebase_merge" {
  type    = bool
  default = false
}
