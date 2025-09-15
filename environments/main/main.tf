data "aws_organizations_organization" "org" {}
resource "aws_organizations_organizational_unit" "project_ou" {
  name      = "projects"
  parent_id = data.aws_organizations_organization.org.roots[0].id
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
}

resource "github_repository" "iac_project_template" {
  name        = "iac-project-template"
  description = "Template repository for new IaC projects"
  visibility  = "private"
  is_template = true
}
