projects = {
  "shared-services" = {
    environments    = ["dev", "prod"]
    code_repo_names = ["shared-services"]
  }
  "vintech-hub" = {
    environments    = ["prod"]
    code_repo_names = ["vintech-hub"]

    code_repo_required_checks = { "vintech-hub" = ["Verify"] }

    developers = ["haraldvinje"]
  }
}
