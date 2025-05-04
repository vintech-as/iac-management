module "github_iac_repo" {
  source = "./../../modules/github-iac-repo"

  for_each = { for repo in var.repository_configs : repo.iac_repo_name => repo }
  
  organization_name     = var.organization_name
  iac_repo_name         = each.value.iac_repo_name
  environment_role_arns = each.value.environment_role_arns
}
