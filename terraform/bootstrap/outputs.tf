output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "terraform_plan_role_arn" {
  description = "IAM role ARN used by GitHub Actions for Terraform plans"
  value       = aws_iam_role.terraform_plan.arn
}