variable "organization" {
  description = "Actual company GitHub organization login."
  type        = string
  nullable    = false
}

variable "enforcement" {
  description = "Start in evaluate or disabled, then activate after the pilot."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["disabled", "evaluate", "active"], var.enforcement)
    error_message = "enforcement must be disabled, evaluate, or active."
  }
}

variable "repository_name_patterns" {
  description = "Repository name patterns to include, for example [\"~ALL\"] or an approved naming group."
  type        = set(string)
  nullable    = false

  validation {
    condition     = length(var.repository_name_patterns) > 0
    error_message = "At least one repository name pattern is required."
  }
}

variable "excluded_repository_names" {
  description = "Exceptions approved for the baseline policy."
  type        = set(string)
  default     = []
}

variable "required_approvals" {
  description = "Minimum PR approvals on the default branch."
  type        = number
  default     = 1

  validation {
    condition     = var.required_approvals >= 1 && var.required_approvals <= 6
    error_message = "required_approvals must be between 1 and 6."
  }
}
