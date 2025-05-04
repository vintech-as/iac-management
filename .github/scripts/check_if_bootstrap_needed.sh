#!/bin/sh

# Count AWS accounts in main state
main_account_count=$(terraform -chdir=environments/main init 1> /dev/null && terraform -chdir=environments/main state list | grep -c "aws_organizations_account.env_account")
echo "Found $main_account_count AWS accounts in main state"

# Count bootstrapped S3 buckets in bootstrap state
bootstrap_bucket_count=$(terraform -chdir=environments/bootstrap init 1> /dev/null && terraform -chdir=environments/bootstrap state list | grep -c "module.account_bootstrap.aws_s3_bucket.tf_state")
echo "Found $bootstrap_bucket_count bootstrapped buckets in bootstrap state"

# Compare counts
if [ $main_account_count -gt $bootstrap_bucket_count ]; then
echo "BOOTSTRAP_NEEDED=true" >> "$GITHUB_OUTPUT"
echo "Bootstrap needed: $main_account_count accounts exist but only $bootstrap_bucket_count are bootstrapped"
else
echo "BOOTSTRAP_NEEDED=false" >> "$GITHUB_OUTPUT"
echo "No bootstrap needed: $bootstrap_bucket_count buckets exist for $main_account_count accounts"
fi