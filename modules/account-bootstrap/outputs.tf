output "iac_role_arn" {
  description = "The ARN of the IAM role for the IaC repository to assume in GitHub Actions"
  value       = aws_iam_role.github_oidc.arn
}
