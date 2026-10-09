variable "organization" {
  description = "GitHub organization that owns this repository."
  type        = string
  default     = "xbrain-org-poc"
}

variable "demo_repository_description" {
  description = "Description of the repository used to demonstrate IaC management."
  type        = string
  default     = "Demo trực tiếp: repository-demo được quản lý bằng Terraform."
}
