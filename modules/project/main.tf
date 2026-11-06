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

  vulnerability_alerts = true
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
