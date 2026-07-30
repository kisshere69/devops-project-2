variable "aws_region" {
    description = "AWS Region for the entire Project"
    type = string
    default =  "eu-central-1"
}

variable "project_name" {
  type = string
  default = "devops-project-2"
}

variable "environment" {
  description = "Deployment environment"
  type = string
  default = "dev"
}

