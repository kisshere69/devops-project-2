output "aws_account_id" {
  description = "AWS Account ID"

  value = data.aws_caller_identity.current.account_id
}

output "aws_caller_arn" {
  description = "Current IAM ARN"

  value = data.aws_caller_identity.current.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}