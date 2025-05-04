resource "github_repository" "iac_repo" {
  name          = var.iac_repo_name
  description   = "Infrastructure as Code repository"
  visibility    = "private"
  has_issues    = true
  has_wiki      = false
  has_downloads = false

  template {
    owner                = var.organization_name
    repository           = "iac-project-template"
  }
}

resource "github_repository_environment" "aws_environments" {
  for_each = var.environment_role_arns

  repository  = github_repository.iac_repo.name
  environment = each.key
}

resource "github_actions_environment_variable" "aws_role_arn" {
  for_each = var.environment_role_arns

  repository    = github_repository.iac_repo.name
  environment   = github_repository_environment.aws_environments[each.key].environment
  variable_name = "AWS_ROLE_ARN"
  value         = each.value
}