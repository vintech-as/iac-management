#!/bin/bash
# File: .github/scripts/process_role_data.sh
set -e

# Path to repo data directory
REPO_DATA_DIR=$1
WORKING_DIR=$2

if [ -z "$GH_TOKEN" ]; then
  echo "GH_TOKEN is not set!"
  exit 1
else
  echo "GH_TOKEN is available (length: ${#GH_TOKEN})"
fi

if [ -z "$REPO_DATA_DIR" ] || [ -z "$WORKING_DIR" ]; then
  echo "Usage: $0 <repo-data-dir> <working-directory>"
  exit 1
fi

# Get list of repo files
repo_files=$(find "$REPO_DATA_DIR" -type f -name "*.txt")

# Check if any files were found
if [ -z "$repo_files" ]; then
  echo "No role ARN data files found in $REPO_DATA_DIR"
  exit 1
fi

# Array to store repo names and env-role mappings
declare -A repo_env_roles

# Process each file to extract data
for file in $repo_files; do
  # Extract repo name and environment from filename
  filename=$(basename "$file")
  name_parts=(${filename//---/ })
  repo_name="${name_parts[0]}"
  env="${name_parts[1]%.txt}"  # Remove .txt extension
  
  # Read the role ARN
  role_arn=$(cat "$file")
  
  echo "Found: repo=$repo_name, env=$env, role=$role_arn"
  
  # Store in associative array
  if [[ -z "${repo_env_roles[$repo_name]}" ]]; then
    repo_env_roles[$repo_name]="{\"$env\":\"$role_arn\"}"
  else
    repo_env_roles[$repo_name]="${repo_env_roles[$repo_name]%\}},\"$env\":\"$role_arn\"}"
  fi
done

# Create and apply for each repo
for repo_name in "${!repo_env_roles[@]}"; do
  echo "Processing repo: $repo_name"
  
  # Change to working directory
  cd "$WORKING_DIR"
  
  # Create tfvars file
  cat > terraform.tfvars.json << EOF
{
  "iac_repo_name": "${repo_name}",
  "environment_role_arns": ${repo_env_roles[$repo_name]}
}
EOF
  
  echo "Created tfvars file:"
  cat terraform.tfvars.json
  
  # Initialize and apply Terraform
  terraform init
  terraform apply -auto-approve
done