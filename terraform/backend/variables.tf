variable "aws_region" {
  description = "The AWS region for the Terraform state bucket"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "state_bucket_name" {
  description = "A unique name of the S3 bucket for Terraform state"
  type        = string
}