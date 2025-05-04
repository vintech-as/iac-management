module "github_iac_repo" {
  source = "./../../modules/github-iac-repo"

  organization_name     = var.organization_name
  iac_repo_name         = var.iac_repo_name
  environment_role_arns = var.environment_role_arns
}