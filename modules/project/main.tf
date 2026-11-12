resource "aws_organizations_organizational_unit" "project_ou" {
  name      = var.project_name
  parent_id = var.parent_ou_id
}

resource "aws_organizations_account" "env_account" {
  for_each = toset(var.environments)

  name              = "${var.project_name}-${each.key}"
  email             = "aws+${var.project_name}-${each.key}@${var.organization_domain}"
  close_on_deletion = true
  parent_id         = aws_organizations_organizational_unit.project_ou.id
  role_name         = "OrganizationAccountAccessRole"
  tags = {
    Project     = var.project_name
    Environment = each.key
  }
}

resource "github_repository" "code_repo" {
  for_each = var.use_code_repo ? toset(var.code_repo_names) : []

  name        = each.key
  description = "Code repository for ${var.project_name}"
  visibility  = "private"
  has_issues  = true
  has_wiki    = false

  # New repos need a first commit: the default branch rules block pushing one.
  auto_init = true

  delete_branch_on_merge = true

  lifecycle {
    ignore_changes = [auto_init]
  }
}

module "code_repo_rules" {
  source   = "../github-default-branch-rules"
  for_each = var.use_code_repo ? toset(var.code_repo_names) : []

  repository      = github_repository.code_repo[each.key].name
  required_checks = lookup(var.code_repo_required_checks, each.key, [])

  require_up_to_date_branch       = try(var.code_repo_branch_rules[each.key].require_up_to_date_branch, false)
  require_conversation_resolution = try(var.code_repo_branch_rules[each.key].require_conversation_resolution, false)
}

resource "github_repository_vulnerability_alerts" "code_repo" {
  for_each = var.use_code_repo ? toset(var.code_repo_names) : []

  repository = github_repository.code_repo[each.key].name
  enabled    = true
}

resource "aws_ssoadmin_account_assignment" "admins" {
  for_each = toset(var.environments)

  instance_arn       = var.sso_instance_arn
  permission_set_arn = var.admin_permission_set_arn
  principal_type     = "GROUP"
  principal_id       = var.admin_group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = aws_organizations_account.env_account[each.key].id
}

# One group per project, so a developer only reaches the projects they work on.
resource "aws_identitystore_group" "developers" {
  count = length(var.developer_users) > 0 ? 1 : 0

  identity_store_id = var.identity_store_id
  display_name      = "${var.project_name}-developers"
  description       = "Read-only developer access to ${var.project_name}"
}

resource "aws_identitystore_group_membership" "developers" {
  for_each = var.developer_users

  identity_store_id = var.identity_store_id
  group_id          = aws_identitystore_group.developers[0].group_id
  member_id         = each.value
}

resource "aws_ssoadmin_account_assignment" "developers" {
  for_each = length(var.developer_users) > 0 ? toset(var.environments) : toset([])

  instance_arn       = var.sso_instance_arn
  permission_set_arn = var.developer_permission_set_arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.developers[0].group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = aws_organizations_account.env_account[each.key].id
}
