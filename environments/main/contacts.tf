# Security and billing alternate contacts for every account in the org, managed
# centrally from the management account. The phone number comes from the
# SECURITY_CONTACT_PHONE GitHub Actions secret, since this repository is public.
locals {
  member_account_ids = merge([
    for project_name, project in var.projects : {
      for env in project.environments :
      "${project_name}-${env}" => module.projects[project_name].account_ids[env]
    }
  ]...)

  # null account_id = the management account itself
  contact_accounts = merge({ management = null }, local.member_account_ids)

  alternate_contacts = merge([
    for account_key, account_id in local.contact_accounts : {
      for type in ["SECURITY", "BILLING"] :
      "${account_key}-${lower(type)}" => { account_id = account_id, type = type }
    }
  ]...)
}

resource "aws_account_alternate_contact" "this" {
  for_each = local.alternate_contacts

  account_id             = each.value.account_id
  alternate_contact_type = each.value.type
  name                   = var.contact_name
  title                  = "Owner"
  email_address          = var.notification_email
  phone_number           = var.contact_phone

  depends_on = [aws_organizations_organization.org]
}
