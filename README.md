# Iac Management

This repository contains [OpenTofu](https://opentofu.org/) (an open source alternative more or less compatible with Terraform) configurations the following:
1. **AWS**: AWS account and organization setup. It serves as the central location for managing AWS account infrastructure, permissions, and organizational structures.
2. **GitHub**: GitHub repositories, teams and organizational policies are managed in this repository.

## Purpose

- Manage AWS Organizations and account structures
- Set up cross-account roles and permissions
- Configure organizational policies
- Establish baseline security settings
- Provision new project accounts
- Configure GitHub

## Development Workflow

1. **Development**
   - Make changes to the `.tf` files in your local environment
   - Test changes locally with `tofu plan` (requires AWS credentials)

2. **Pull Request**
   - Create a PR with your changes
   - The tofu-init-validate-plan-comment workflow will automatically, for each of the three stages (`main`, `bootstrap` and `project-iac-repo`):
     - Initialize OpenTofu
     - Validate the configuration
     - Generate a plan
     - Comment the plan on your PR, one comment per stage
   - A later stage plans against what the stage before it last applied. If your PR changes `main`'s outputs too, the later stages only see that once `main` is applied.

3. **Review & Merge**
   - Review the generated plan in the PR comments
   - Once approved, merge to the `master` branch

4. **Approval & Apply**
   - Run the tofu-apply workflow by hand. It goes through the stages in order, `main`, then `bootstrap`, then `project-iac-repo`, and for each:
     - Runs another tofu plan
     - If the plan has changes, creates an approval request in GitHub Issues and waits for approval from authorized approvers
     - Applies the changes once approved
   - A stage without changes is passed without asking, so a change to one stage needs one approval. Each stage reads the outputs the stage before it last applied from that stage's state, so it doesn't need that stage to change in the same run. A rejected approval stops the stages after it.

## Adding New Projects

To provision new AWS accounts and GitHub repos for a project:

1. Edit the `config/projects.tfvars` file to add a new project entry:

   ```hcl
   projects = {
     "existing-project" = {
       environments  = ["dev", "prod"]
       code_repo_names = ["existing-project"]
     },

     "new-project-name" = {
       environments  = ["dev", "prod", "stage"], # List of environments to create accounts for
       code_repo_names = ["custom-repo-name"]       # Optional: defaults to project name if omitted
     }
   }

2. Each project entry will:
   - Create an AWS account for each environment listed
   - Set up a GitHub code repository
   - Create an infrastructure as code (IaC) repository based on the [IaC project template repo](https://github.com/vintech-as/iac-project-template)
   - Bootstrap each account with a S3 bucket for OpenTofu state and a GitHub OIDC provider to make AWS accessible from the newly created IaC GitHub repo.

3. Optionally, add `code_repo_required_checks = { "repo-name" = ["Check name"] }` to require status checks before merging to a code repository's default branch. Add it after the check has run at least once, so the name matches the job name in the workflow.

4. Optionally, add `iac_repo_required_checks = ["Check name"]` to require status checks before merging to the project's IaC repository. Its checks are named after the environment, such as `Prod - OpenTofu Plan, Validate, and Comment / OpenTofu Init, Validate, Plan and Comment`. As with code repositories, add it after the check has run once.

5. Optionally, add `code_repo_branch_rules = { "repo-name" = { require_up_to_date_branch = true, require_conversation_resolution = true } }` for stricter merges. Both are off by default. An up-to-date requirement holds back automerged dependency updates until they're rebased.

6. Optionally, add `developers = ["user-name"]` to give those Identity Center users read-only access to every account of the project. It creates a `<project>-developers` group with the `Developer` permission set: AWS's `ViewOnlyAccess` plus a policy named `developer-access`, which the project defines in its own IaC repo. Apply that policy there first, or the account assignment fails. A user must be in `local.identity_users` in `environments/main/identity-center.tf`.

## Removing Projects

Removing a project requires removing the entry in `config/projects.tfvars`, as well as some manual steps:

1. Remove the entry in `config/projects.tfvars`. Since closing accounts require manual intervention, `tofu apply` will fail to destroy some of the resources. Therefore, the following steps are required.
2. Go to the AWS Management Console, navigate to AWS Organizations and move the accounts from the project OU to the root OU
3. Close the project accounts
4. Re-run failed jobs in GitHub actions which will remove the project OU from the AWS Organization
5. Remove the GitHub IaC repository, either manually or via OpenTofu locally. If manually removed, remember to remove the entry in the OpenTofu state file (by using e.g. `tofu rm`)

## Prerequisites

- OpenTofu (version specified in `.tool-versions`)