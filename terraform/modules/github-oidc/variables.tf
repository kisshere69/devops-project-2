variable "github_repository" {
  description = "GitHub repository allowed to assume the IAM role"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the IAM role"
  type        = string
  default     = "main"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster where GitHub Actions receives access"
  type        = string
}

variable "github_oidc_subject" {
  description = "Exact GitHub OIDC subject allowed to assume the IAM role"
  type        = string
}