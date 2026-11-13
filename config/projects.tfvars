projects = {
  "shared-services" = {
    environments    = ["dev", "prod"]
    code_repo_names = ["shared-services"]
  }
  "vintech-hub" = {
    environments    = ["prod"]
    code_repo_names = ["vintech-hub"]

    code_repo_required_checks = { "vintech-hub" = ["Verify"] }
    iac_repo_required_checks  = ["Prod - OpenTofu Plan, Validate, and Comment / OpenTofu Init, Validate, Plan and Comment"]
    code_repo_branch_rules = {
      "vintech-hub" = { require_up_to_date_branch = true, require_conversation_resolution = true }
    }

    developers = ["haraldvinje"]
  }
}
