locals {
  # Each project's IaC repository is named iac-<project>, as in main's outputs.
  iac_repo_required_checks = {
    for name, project in var.projects : "iac-${name}" => try(project.iac_repo_required_checks, [])
  }
}

module "github_iac_repo" {
  source = "./../../modules/github-iac-repo"

  for_each = var.iac_repo_configs

  organization_name     = var.organization_name
  iac_repo_name         = each.value.repo_name
  environment_role_arns = each.value.environments
  required_checks       = lookup(local.iac_repo_required_checks, each.value.repo_name, [])
}
