output "bootstrap_configs" {
  description = "List of repositories with their associated environment-to-account mappings for bootstrapping"
  value = [
    for repo_name, tuples in {
      for tuple in flatten([
        for project_name, project in var.projects : [
          for env in project.environments : {
            iac_repo_name = "iac-${project_name}"
            account_id    = module.projects[project_name].account_ids[env]
            environment   = env
          }
        ]
      ]) : tuple.iac_repo_name => tuple...
    } : {
      iac_repo_name = repo_name
      environment_to_account_ids = {
        for tuple in tuples : tuple.environment => tuple.account_id
      }
    }
  ]
}
