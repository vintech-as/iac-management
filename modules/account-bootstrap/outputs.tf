output "iac_role_arn" {
  description = "The ARN of the IAM role for the IaC repository to assume in GitHub Actions"
  value       = aws_iam_role.github_oidc.arn
}

output "iac_repo_name" {
  description = "The name of the IaC repository"
  value       = var.iac_repo_name
}

output "environment" {
  description = "The name of the AWS environment"
  value       = var.environment
}
