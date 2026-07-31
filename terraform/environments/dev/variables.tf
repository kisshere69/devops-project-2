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