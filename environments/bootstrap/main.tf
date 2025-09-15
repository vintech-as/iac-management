locals {
  account_repo_tuples = flatten([
    for config in var.bootstrap_configs : [
      for env, account_id in config.environment_to_account_ids : {
        account_id    = account_id
        iac_repo_name = config.iac_repo_name
        environment   = env
      }
    ]
  ])

  all_account_ids = { for tuple in local.account_repo_tuples : tuple.account_id => tuple.account_id... }
  provider_map    = { for account_id, _ in local.all_account_ids : account_id => account_id }

  bootstrap_map = {
    for tuple in local.account_repo_tuples :
    "${tuple.iac_repo_name}-${tuple.account_id}" => tuple
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "default"
}

provider "aws" {
  region = "eu-west-1"

  for_each = local.provider_map
  alias    = "by_account"

  assume_role {
    role_arn = "arn:aws:iam::${each.key}:role/OrganizationAccountAccessRole"
  }
}

module "account_bootstrap" {
  source = "../../modules/account-bootstrap"

  for_each = local.bootstrap_map

  account_id        = each.value.account_id
  organization_name = var.organization_name
  iac_repo_name     = each.value.iac_repo_name
  environment       = each.value.environment
  providers = {
    aws = aws.by_account[each.value.account_id]
  }
}
