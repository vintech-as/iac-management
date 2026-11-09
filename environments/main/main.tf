resource "aws_organizations_organizational_unit" "project_ou" {
  name      = "projects"
  parent_id = aws_organizations_organization.org.roots[0].id
}

module "projects" {
  for_each = var.projects

  source              = "./../../modules/project"
  project_name        = each.key
  organization_domain = var.organization_domain
  environments        = each.value.environments
  use_code_repo       = lookup(each.value, "use_code_repo", true)
  code_repo_names     = each.value.code_repo_names
  parent_ou_id        = aws_organizations_organizational_unit.project_ou.id

  sso_instance_arn         = local.sso_instance_arn
  admin_permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
  admin_group_id           = aws_identitystore_group.administrators.group_id

  code_repo_required_checks = each.value.code_repo_required_checks
}

resource "github_repository" "iac_project_template" {
  name        = "iac-project-template"
  description = "Template repository for new IaC projects"
  visibility  = "public"
  is_template = true

  delete_branch_on_merge = true
}

module "iac_project_template_rules" {
  source = "./../../modules/github-default-branch-rules"

  repository = github_repository.iac_project_template.name
}

# This repository isn't itself managed here, so it's referenced by name.
module "iac_management_rules" {
  source = "./../../modules/github-default-branch-rules"

  repository = "iac-management"
}
