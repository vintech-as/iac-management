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
   - The tofu-init-validate-plan-comment workflow will automatically:
     - Initialize OpenTofu
     - Validate the configuration
     - Generate a plan
     - Comment the plan on your PR

3. **Review & Merge**
   - Review the generated plan in the PR comments
   - Once approved, merge to the `master` branch

4. **Approval & Apply**
   - The tofu-apply workflow will:
     - Run another tofu plan
     - Create an approval request in GitHub Issues
     - Wait for manual approval from authorized approvers
     - Apply the changes once approved

## Adding New Projects

To provision new AWS accounts and GitHub repos for a project:

1. Edit the `config/projects.tfvars` file to add a new project entry:

   ```hcl
   projects = {
     "existing-project" = {
       environments  = ["dev", "prod"]
       code_repo_name = "existing-project"
     },
     
     "new-project-name" = {
       environments  = ["dev", "prod", "stage"], # List of environments to create accounts for
       code_repo_name = "custom-repo-name"       # Optional: defaults to project name if omitted
     }
   }

2. Each project entry will:
   - Create an AWS account for each environment listed 
   - Set up a GitHub code repository
   - Create an infrastructure as code (IaC) repository based on the [IaC project template repo](https://github.com/vintech-as/iac-project-template)
   - Bootstrap each account with a S3 bucket for OpenTofu state and a GitHub OIDC provider to make AWS accessible from the newly created IaC GitHub repo.

## Removing Projects

Removing a project requires removing the entry in `config/projects.tfvars`, as well as some manual steps:

1. Remove the entry in `config/projects.tfvars`. Since closing accounts require manual intervention, `tofu apply` will fail to destroy some of the resources. Therefore, the following steps are required.
2. Go to the AWS Management Console, navigate to AWS Organizations and move the accounts from the project OU to the root OU
3. Close the project accounts
4. Re-run failed jobs in GitHub actions which will remove the project OU from the AWS Organization
5. Remove the GitHub IaC repository, either manually or via OpenTofu locally. If manually removed, remember to remove the entry in the OpenTofu state file (by using e.g. `tofu rm`)

## Prerequisites

- OpenTofu (version specified in `.tool-versions`)