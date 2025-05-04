module "account_bootstrap" {
  source = "../../modules/account-bootstrap"

  account_id        = var.account_id
  organization_name = var.organization_name
  iac_repo_name     = var.iac_repo_name
}
