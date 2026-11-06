# The AWS Organization itself. Deleting this resource would delete the organization,
# so it is protected with prevent_destroy.
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "iam.amazonaws.com", # centralized root access management
    "sso.amazonaws.com", # IAM Identity Center
  ]

  enabled_policy_types = []

  lifecycle {
    prevent_destroy = true
  }
}

# Centralized root access: member accounts have no root credentials, and root
# sessions can be started from the management account when needed.
resource "aws_iam_organizations_features" "root_access" {
  enabled_features = [
    "RootCredentialsManagement",
    "RootSessions",
  ]

  depends_on = [aws_organizations_organization.org]
}
