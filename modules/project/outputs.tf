output "account_ids" {
  description = "Map of environments to their AWS account IDs"
  value = {
    for env, account in aws_organizations_account.env_account :
    env => account.id
  }
}