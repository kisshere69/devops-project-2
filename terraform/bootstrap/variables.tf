variable "aws_region" {
  description = "AWS region used by the project"
  type        = string
  default     = "eu-central-1"
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

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI role"
  type        = string
  default     = "kisshere69/devops-project-2"
}