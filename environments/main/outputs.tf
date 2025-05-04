output "repo_account_tuples" {
  description = "Flattened list of repo name, account ID and environment tuples"
  value = flatten([
    for project_name, project in var.projects : [
      for env in project.environments : {
        repo_name   = "iac-${project_name}"
        account_id  = module.projects[project_name].account_ids[env]
        environment = env
      }
    ]
  ])
}
