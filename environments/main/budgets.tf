# Org-wide monthly cost budget. A budget in the management account covers the
# consolidated bill of all member accounts. Per-account budgets (e.g. sandbox)
# are defined next to those accounts.
resource "aws_budgets_budget" "org_monthly" {
  name         = "org-monthly-cost"
  budget_type  = "COST"
  limit_amount = var.org_monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [var.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "FORECASTED"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = [var.notification_email]
  }
}
