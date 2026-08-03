variable "cluster_name" {
  description = "Amazon EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Amazon EKS Kubernetes version"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}