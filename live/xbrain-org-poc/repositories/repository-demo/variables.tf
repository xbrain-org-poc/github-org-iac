variable "organization" {
  description = "GitHub organization that owns this repository."
  type        = string
  default     = "xbrain-org-poc"
}

variable "demo_repository_description" {
  description = "Description of the repository used to demonstrate IaC management."
  type        = string
  default     = "PoC thành công: repository và ruleset được quản lý bằng Terraform."
}
