# The AWS Organization itself. Deleting this resource would delete the organization,
# so it is protected with prevent_destroy.
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"

  aws_service_access_principals = [
    "access-analyzer.amazonaws.com", # org-wide external access analyzer
    "account.amazonaws.com",         # manage alternate contacts centrally
    "cloudtrail.amazonaws.com",      # organization trail
    "iam.amazonaws.com",             # centralized root access management
    "sso.amazonaws.com",             # IAM Identity Center
  ]

  # Enabling SCPs automatically attaches the AWS-managed FullAWSAccess policy
  # to the root, every OU and every account; custom SCPs then only deny.
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]

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
