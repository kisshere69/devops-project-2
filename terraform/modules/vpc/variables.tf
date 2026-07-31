variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment"
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
  description = "Availability zone for Public Subnet A"
  type        = string
}