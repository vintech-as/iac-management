module "github_iac_repo" {
  source = "./../../modules/github-iac-repo"

  for_each = var.iac_repo_configs

  organization_name     = var.organization_name
  iac_repo_name         = each.value.repo_name
  environment_role_arns = each.value.environments
}
