# AWS common variables

variable "aws_region" {
  description = "AWS region used by the project"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

# EKS variables

variable "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster where GitHub Actions receives access"
  type        = string
}

# GitHub variables

variable "github_oidc_subject" {
  description = "Exact GitHub OIDC subject allowed to assume the IAM role"
  type        = string
}

variable "github_oidc_provider_arn" {
  description = "ARN of the shared GitHub Actions OIDC provider"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the IAM role"
  type        = string
}

variable "repository_name" {
  description = "Amazon ECR repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume the IAM role"
  type        = string
  default     = "main"
}