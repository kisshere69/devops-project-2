variable "aws_region" {
  description = "AWS region used by the project"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "devops-project-2"
}

variable "environment" {
  description = "Bootstrap environment name"
  type        = string
  default     = "shared"
}

variable "github_oidc_subjects" {
  description = "GitHub OIDC subjects allowed to assume the Terraform plan role"
  type        = list(string)
}

variable "terraform_state_bucket" {
  description = "S3 bucket containing Terraform remote state"
  type        = string
}