data "aws_ssoadmin_instances" "this" {}

locals {
  sso_instance_arn  = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_identitystore_group" "administrators" {
  identity_store_id = local.identity_store_id
  display_name      = "Administrators"
}

resource "aws_identitystore_user" "harald" {
  identity_store_id = local.identity_store_id
  user_name         = "haraldvinje"
  display_name      = "Harald Vinje"

  name {
    given_name  = "Harald"
    family_name = "Vinje"
  }

  emails {
    value   = "harald@vintech.no"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_group_membership" "harald_administrators" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.administrators.group_id
  member_id         = aws_identitystore_user.harald.user_id
}

resource "aws_ssoadmin_permission_set" "administrator_access" {
  instance_arn     = local.sso_instance_arn
  name             = "AdministratorAccess"
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator_access" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Management account access. Project accounts get their assignment in the project module.
resource "aws_ssoadmin_account_assignment" "management_administrators" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.administrators.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = aws_organizations_organization.org.master_account_id
}

# Read-only access for project developers, coding agents included. ViewOnlyAccess
# shows resources and settings but no data. Each project account adds what its
# developers need through a policy named developer-access, defined in the
# project's own IaC repo, so it must exist there before a project is assigned.
resource "aws_ssoadmin_permission_set" "developer" {
  instance_arn     = local.sso_instance_arn
  name             = "Developer"
  description      = "View-only access plus the project's developer-access policy"
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "developer_view_only" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "developer_project_access" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn

  customer_managed_policy_reference {
    name = "developer-access"
  }
}

# Users a project can list as developers in config/projects.tfvars.
locals {
  identity_users = {
    (aws_identitystore_user.harald.user_name) = aws_identitystore_user.harald.user_id
  }
}
