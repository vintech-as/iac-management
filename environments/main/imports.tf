# One-time imports of resources created by hand before they were managed here.
# Safe to delete this file once these have been applied.

import {
  to = aws_organizations_organization.org
  id = "o-koqsgn6gto"
}

import {
  to = aws_iam_organizations_features.root_access
  id = "o-koqsgn6gto"
}

import {
  to = aws_iam_openid_connect_provider.github
  id = "arn:aws:iam::061286906622:oidc-provider/token.actions.githubusercontent.com"
}

import {
  to = aws_iam_role.github_actions_deploy
  id = "GitHubActionsDeployRole"
}

import {
  to = aws_iam_role_policy_attachment.github_actions_deploy_admin
  id = "GitHubActionsDeployRole/arn:aws:iam::aws:policy/AdministratorAccess"
}

import {
  to = aws_s3_bucket.tofu_state
  id = "vintech-terraform-state-eu-west-1"
}

import {
  to = aws_s3_bucket_versioning.tofu_state
  id = "vintech-terraform-state-eu-west-1"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.tofu_state
  id = "vintech-terraform-state-eu-west-1"
}

import {
  to = aws_s3_bucket_public_access_block.tofu_state
  id = "vintech-terraform-state-eu-west-1"
}

import {
  to = aws_s3_bucket_ownership_controls.tofu_state
  id = "vintech-terraform-state-eu-west-1"
}

import {
  to = aws_identitystore_group.administrators
  id = "d-9367a3c270/c265b4a4-1021-705d-a90e-5323ebb3dd94"
}

import {
  to = aws_identitystore_user.harald
  id = "d-9367a3c270/e28544c4-c091-7000-4333-e7866e8d9243"
}

import {
  to = aws_identitystore_group_membership.harald_administrators
  id = "d-9367a3c270/82f58464-d0a1-708f-91d0-37ab860d8673"
}

import {
  to = aws_ssoadmin_permission_set.administrator_access
  id = "arn:aws:sso:::permissionSet/ssoins-680445a21719830a/ps-8b7822dd018104af,arn:aws:sso:::instance/ssoins-680445a21719830a"
}

import {
  to = aws_ssoadmin_managed_policy_attachment.administrator_access
  id = "arn:aws:iam::aws:policy/AdministratorAccess,arn:aws:sso:::permissionSet/ssoins-680445a21719830a/ps-8b7822dd018104af,arn:aws:sso:::instance/ssoins-680445a21719830a"
}

import {
  to = aws_ssoadmin_account_assignment.management_administrators
  id = "c265b4a4-1021-705d-a90e-5323ebb3dd94,GROUP,061286906622,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-680445a21719830a/ps-8b7822dd018104af,arn:aws:sso:::instance/ssoins-680445a21719830a"
}

import {
  to = module.projects["shared-services"].aws_ssoadmin_account_assignment.admins["dev"]
  id = "c265b4a4-1021-705d-a90e-5323ebb3dd94,GROUP,236340615919,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-680445a21719830a/ps-8b7822dd018104af,arn:aws:sso:::instance/ssoins-680445a21719830a"
}

import {
  to = module.projects["shared-services"].aws_ssoadmin_account_assignment.admins["prod"]
  id = "c265b4a4-1021-705d-a90e-5323ebb3dd94,GROUP,106403002032,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-680445a21719830a/ps-8b7822dd018104af,arn:aws:sso:::instance/ssoins-680445a21719830a"
}
