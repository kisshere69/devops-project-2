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