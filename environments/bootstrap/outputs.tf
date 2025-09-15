output "iac_repo_configs" {
  value = {
    for repo_name in distinct([for _, bootstrap in module.account_bootstrap : bootstrap.iac_repo_name]) : repo_name => {
      repo_name = repo_name
      environments = {
        for key, bootstrap in module.account_bootstrap :
        bootstrap.environment => bootstrap.iac_role_arn
        if bootstrap.iac_repo_name == repo_name
      }
    }
  }
  description = "Repository configurations grouped by name for direct use in the project-iac-repo module"
}
