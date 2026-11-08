# Sandbox: a single disposable account for experiments (Bedrock/GenAI etc.).
# It sits in its own OU, outside the project pipeline (no tofu state bucket or
# project IaC repo). Contents are deployed with CDK from the vintech-sandbox repo.
#
# Guardrails here are enforced from the management account, so nothing inside
# the sandbox can loosen them:
#   - sandbox-region-restriction SCP
#   - sandbox-cost-guardrails SCP
#   - monthly budget: email alerts, plus a hard stop that attaches sandbox-freeze

locals {
  sandbox_name = "vintech-sandbox"

  # Regions for regular (non-Bedrock) workloads.
  sandbox_workload_regions = [
    "eu-west-1",
    "eu-north-1",
    "eu-central-1",
    "us-east-1",
    "us-west-2",
  ]

  # Bedrock cross-Region inference destinations: every region the eu.* and us.*
  # profiles route to, plus "unspecified", which global.* profiles use.
  sandbox_bedrock_regions = [
    "eu-central-1", "eu-north-1", "eu-south-1", "eu-south-2", "eu-west-1", "eu-west-3",
    "us-east-1", "us-east-2", "us-west-1", "us-west-2",
    "unspecified",
  ]

  # Global or us-east-1-only services, exempt from the workload region rule.
  # Bedrock is exempted here and gets its own statement.
  sandbox_region_exempt_actions = [
    "a4b:*", "access-analyzer:*", "account:*", "acm:*", "aws-marketplace-management:*",
    "aws-marketplace:*", "aws-portal:*", "bedrock:*", "billing:*", "budgets:*", "ce:*",
    "chime:*", "cloudfront:*", "config:*", "cur:*", "directconnect:*",
    "ec2:DescribeRegions", "ec2:DescribeTransitGateways", "ec2:DescribeVpnGateways",
    "fms:*", "freetier:*", "globalaccelerator:*", "health:*", "iam:*", "identitystore:*",
    "importexport:*", "invoicing:*", "kms:*", "networkmanager:*", "organizations:*",
    "payments:*", "pricing:*", "route53-recovery-cluster:*",
    "route53-recovery-control-config:*", "route53-recovery-readiness:*", "route53:*",
    "route53domains:*", "s3:CreateMultiRegionAccessPoint", "s3:GetAccountPublic*",
    "s3:ListAllMyBuckets", "s3:ListMultiRegionAccessPoints", "s3:PutAccountPublic*",
    "shield:*", "sso:*", "sts:*", "support:*", "tax:*", "trustedadvisor:*",
    "waf-regional:*", "waf:*", "wafv2:*", "wellarchitected:*",
  ]

  # GPU/accelerator families, bare metal and 8xlarge and up.
  sandbox_denied_ec2_types = [
    "g*", "p*", "trn*", "inf*", "dl*", "f*", "vt*", "hpc*", "u-*", "x*",
    "*.metal*", "*.8xlarge", "*.9xlarge", "*.1?xlarge", "*.2?xlarge", "*.3?xlarge",
    "*.4?xlarge", "*.5?xlarge",
  ]
  sandbox_denied_sagemaker_types = [
    "ml.g*", "ml.p*", "ml.trn*", "ml.inf*", "ml.dl*", "ml.x*", "ml.*.metal*",
    "ml.*.8xlarge", "ml.*.9xlarge", "ml.*.1?xlarge", "ml.*.2?xlarge", "ml.*.3?xlarge",
    "ml.*.4?xlarge",
  ]

  org_access_role_arn_pattern = "arn:aws:iam::*:role/OrganizationAccountAccessRole"
}

# ---------------------------------------------------------------------------
# OU, account, access
# ---------------------------------------------------------------------------

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "sandbox"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "sandbox" {
  name              = local.sandbox_name
  email             = "aws+sandbox@${var.organization_domain}"
  parent_id         = aws_organizations_organizational_unit.sandbox.id
  role_name         = "OrganizationAccountAccessRole"
  close_on_deletion = true

  tags = {
    Project     = "sandbox"
    Environment = "sandbox"
  }
}

resource "aws_ssoadmin_permission_set" "sandbox_admin" {
  instance_arn     = local.sso_instance_arn
  name             = "SandboxAdmin"
  description      = "Admin access to the sandbox account with long sessions"
  session_duration = "PT8H"
}

resource "aws_ssoadmin_managed_policy_attachment" "sandbox_admin" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sandbox_admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "sandbox_admins" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sandbox_admin.arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.administrators.group_id
  target_type        = "AWS_ACCOUNT"
  target_id          = aws_organizations_account.sandbox.id

  depends_on = [aws_ssoadmin_managed_policy_attachment.sandbox_admin]
}

resource "github_repository" "sandbox" {
  name        = local.sandbox_name
  description = "Sandbox experiments (AWS CDK) deployed to the vintech-sandbox account"
  visibility  = "private"
  has_issues  = true
  has_wiki    = false
  auto_init   = true

  delete_branch_on_merge = true
}

# Experiments are pushed straight to the default branch.
module "sandbox_repo_rules" {
  source = "./../../modules/github-default-branch-rules"

  repository           = github_repository.sandbox.name
  require_pull_request = false
}

# ---------------------------------------------------------------------------
# SCPs (split by concern; each stays well under the 5120 character SCP limit)
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "sandbox_region_restriction" {
  statement {
    sid         = "DenyWorkloadsOutsideAllowedRegions"
    effect      = "Deny"
    not_actions = local.sandbox_region_exempt_actions
    resources   = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = local.sandbox_workload_regions
    }
  }

  statement {
    sid       = "DenyBedrockOutsideInferenceRegions"
    effect    = "Deny"
    actions   = ["bedrock:*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = local.sandbox_bedrock_regions
    }
  }
}

data "aws_iam_policy_document" "sandbox_cost_guardrails" {
  statement {
    sid    = "DenyCommitmentsAndCostlySubscriptions"
    effect = "Deny"
    actions = [
      "bedrock:CreateProvisionedModelThroughput",
      "bedrock:UpdateProvisionedModelThroughput",
      "dynamodb:PurchaseReservedCapacityOfferings",
      "ec2:AllocateHosts",
      "ec2:PurchaseHostReservation",
      "ec2:PurchaseReservedInstancesOffering",
      "ec2:PurchaseScheduledInstances",
      "elasticache:PurchaseReservedCacheNodesOffering",
      "es:PurchaseReservedInstanceOffering",
      "rds:PurchaseReservedDBInstancesOffering",
      "redshift:PurchaseReservedNodeOffering",
      "route53domains:RegisterDomain",
      "route53domains:TransferDomain",
      "savingsplans:CreateSavingsPlan",
      "shield:CreateSubscription",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyLargeOrAcceleratedEc2"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringLike"
      variable = "ec2:InstanceType"
      values   = local.sandbox_denied_ec2_types
    }
  }

  statement {
    sid    = "DenyLargeOrAcceleratedSageMaker"
    effect = "Deny"
    actions = [
      "sagemaker:CreateApp",
      "sagemaker:CreateCluster",
      "sagemaker:CreateEndpointConfig",
      "sagemaker:CreateHyperParameterTuningJob",
      "sagemaker:CreateNotebookInstance",
      "sagemaker:CreateProcessingJob",
      "sagemaker:CreateTrainingJob",
      "sagemaker:CreateTransformJob",
    ]
    resources = ["*"]

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "sagemaker:InstanceTypes"
      values   = local.sandbox_denied_sagemaker_types
    }
  }

  # No long-lived credentials: stolen access keys are the usual way into
  # Bedrock abuse ("LLMjacking"). Use Identity Center sessions instead.
  statement {
    sid    = "DenyLongLivedCredentials"
    effect = "Deny"
    actions = [
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:CreateUser",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "sandbox_region_restriction" {
  name        = "sandbox-region-restriction"
  description = "Sandbox: workloads in approved regions; Bedrock in all EU/US inference regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode(jsondecode(data.aws_iam_policy_document.sandbox_region_restriction.json))
}

resource "aws_organizations_policy" "sandbox_cost_guardrails" {
  name        = "sandbox-cost-guardrails"
  description = "Sandbox: deny commitments, large/accelerated instances and long-lived credentials"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode(jsondecode(data.aws_iam_policy_document.sandbox_cost_guardrails.json))
}

resource "aws_organizations_policy_attachment" "sandbox_region_restriction" {
  policy_id = aws_organizations_policy.sandbox_region_restriction.id
  target_id = aws_organizations_organizational_unit.sandbox.id
}

resource "aws_organizations_policy_attachment" "sandbox_cost_guardrails" {
  policy_id = aws_organizations_policy.sandbox_cost_guardrails.id
  target_id = aws_organizations_organizational_unit.sandbox.id
}

# ---------------------------------------------------------------------------
# Budget with hard stop
# ---------------------------------------------------------------------------

# Attached to the sandbox account by the budget action when the hard limit is
# reached. Denies everything except OrganizationAccountAccessRole, which stays
# usable from the management account so resources can still be cleaned up.
# To unfreeze: clean up, then detach this policy from the account (or reset the
# budget action in the console).
data "aws_iam_policy_document" "sandbox_freeze" {
  statement {
    sid       = "FreezeSandbox"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = [local.org_access_role_arn_pattern]
    }
  }
}

resource "aws_organizations_policy" "sandbox_freeze" {
  name        = "sandbox-freeze"
  description = "Attached by the sandbox budget hard stop. Denies all but OrganizationAccountAccessRole."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.sandbox_freeze.json
}

resource "aws_budgets_budget" "sandbox" {
  name         = "sandbox-monthly-cost"
  budget_type  = "COST"
  limit_amount = var.sandbox_budget_hard_stop_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "LinkedAccount"
    values = [aws_organizations_account.sandbox.id]
  }

  dynamic "notification" {
    for_each = var.sandbox_budget_alerts_usd
    content {
      comparison_operator        = "GREATER_THAN"
      notification_type          = "ACTUAL"
      threshold                  = notification.value
      threshold_type             = "ABSOLUTE_VALUE"
      subscriber_email_addresses = [var.notification_email]
    }
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [var.notification_email]
  }
}

data "aws_iam_policy_document" "budgets_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [aws_organizations_organization.org.master_account_id]
    }
  }
}

resource "aws_iam_role" "budgets_sandbox_freeze" {
  name               = "BudgetsSandboxFreezeRole"
  assume_role_policy = data.aws_iam_policy_document.budgets_assume.json
}

data "aws_iam_policy_document" "budgets_sandbox_freeze" {
  statement {
    actions = [
      "organizations:AttachPolicy",
      "organizations:DetachPolicy",
    ]
    resources = [
      aws_organizations_policy.sandbox_freeze.arn,
      "arn:aws:organizations::${aws_organizations_organization.org.master_account_id}:account/${aws_organizations_organization.org.id}/${aws_organizations_account.sandbox.id}",
    ]
  }

  statement {
    actions = [
      "organizations:DescribePolicy",
      "organizations:ListPoliciesForTarget",
      "organizations:ListTargetsForPolicy",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "budgets_sandbox_freeze" {
  name   = "attach-sandbox-freeze-scp"
  role   = aws_iam_role.budgets_sandbox_freeze.id
  policy = data.aws_iam_policy_document.budgets_sandbox_freeze.json
}

resource "aws_budgets_budget_action" "sandbox_hard_stop" {
  budget_name        = aws_budgets_budget.sandbox.name
  action_type        = "APPLY_SCP_POLICY"
  approval_model     = "AUTOMATIC"
  notification_type  = "ACTUAL"
  execution_role_arn = aws_iam_role.budgets_sandbox_freeze.arn

  action_threshold {
    action_threshold_type  = "ABSOLUTE_VALUE"
    action_threshold_value = tonumber(var.sandbox_budget_hard_stop_usd)
  }

  definition {
    scp_action_definition {
      policy_id  = aws_organizations_policy.sandbox_freeze.id
      target_ids = [aws_organizations_account.sandbox.id]
    }
  }

  subscriber {
    address           = var.notification_email
    subscription_type = "EMAIL"
  }

  depends_on = [aws_iam_role_policy.budgets_sandbox_freeze]
}
