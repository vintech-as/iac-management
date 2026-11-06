# Baseline service control policy attached at the organization root.
# SCPs never apply to the management account, only to member accounts.
#
# Deliberately NOT included: a "deny root user" statement. Member accounts have
# no root credentials (centralized root access), and such a statement would also
# block the sts:AssumeRoot sessions used for privileged recovery tasks.
# Region restrictions are applied per OU (sandbox), not here.
data "aws_iam_policy_document" "baseline_guardrails" {
  statement {
    sid       = "DenyLeavingOrganization"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }

  statement {
    sid       = "DenyRegionOptInChanges"
    effect    = "Deny"
    actions   = ["account:EnableRegion", "account:DisableRegion"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyAlternateContactChanges"
    effect = "Deny"
    actions = [
      "account:PutAlternateContact",
      "account:DeleteAlternateContact",
    ]
    resources = ["*"]
  }

  # OrganizationAccountAccessRole is the break-glass path from the management
  # account (and what the bootstrap stack uses). Only the role itself may change it.
  statement {
    sid    = "ProtectOrganizationAccountAccessRole"
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
    resources = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]

    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/OrganizationAccountAccessRole"]
    }
  }
}

resource "aws_organizations_policy" "baseline_guardrails" {
  name        = "baseline-guardrails"
  description = "Org-wide deny guardrails for all member accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.baseline_guardrails.json

  depends_on = [aws_organizations_organization.org]
}

resource "aws_organizations_policy_attachment" "baseline_guardrails_root" {
  policy_id = aws_organizations_policy.baseline_guardrails.id
  target_id = aws_organizations_organization.org.roots[0].id
}

# Org-wide analyzer for resources shared outside the organization (free tier).
resource "aws_accessanalyzer_analyzer" "org" {
  analyzer_name = "org-external-access"
  type          = "ORGANIZATION"

  depends_on = [aws_organizations_organization.org]
}
