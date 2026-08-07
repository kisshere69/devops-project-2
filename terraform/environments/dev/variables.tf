variable "aws_region" {
  description = "AWS Region for the entire Project"
  type        = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for Public Subnet A"
  type        = string
}

variable "az_a" {
  description = "Primary Availability Zone"
  type        = string
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for Public Subnet B"
  type        = string
}

variable "az_b" {
  description = "Secondary Availability Zone"
  type        = string
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for Private Subnet A"
  type        = string
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for Private Subnet B"
  type        = string
}

variable "repository_name" {
  description = "Amazon ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string

  default = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning"

  type    = bool
  default = true
}

variable "cluster_version" {
  description = "Amazon EKS Kubernetes version"
  type        = string
}

# EKS Managed Node Group Variables

variable "node_group_name" {
  description = "Name of the EKS managed node group"
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS node group"
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_disk_size" {
  description = "Worker node root volume size in GiB"
  type        = number
}

# GitHub OIDC Variables

variable "github_repository" {
  description = "GitHub repository in owner/repository format"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to deploy"
  type        = string
  default     = "main"
}

variable "github_oidc_provider_arn" {
  description = "ARN of the shared GitHub Actions OIDC provider"
  type        = string
}

variable "github_oidc_subject" {
  description = "value"
  type        = string
}