# Cost Anomaly Detection (free). AWS created the default services monitor and
# subscription when Cost Explorer was first enabled; they are imported here.
# Detection runs on billing data a few times a day, so it is no faster than
# budgets. It catches unusual spend that stays below the fixed budget alerts.

# Whole-org spend, split per AWS service.
resource "aws_ce_anomaly_monitor" "services" {
  name              = "Default-Services-Monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

# Sandbox spend on its own, so its anomalies don't drown in org totals.
resource "aws_ce_anomaly_monitor" "sandbox" {
  name         = "sandbox-account"
  monitor_type = "CUSTOM"

  monitor_specification = jsonencode({
    And            = null
    CostCategories = null
    Dimensions = {
      Key          = "LINKED_ACCOUNT"
      MatchOptions = null
      Values       = [aws_organizations_account.sandbox.id]
    }
    Not               = null
    Or                = null
    ProductAttributes = null
    Tags              = null
  })
}

# Daily email digest of anomalies with at least this much total impact.
# The AWS default (USD 100 and 40 %) was far too high for this org's spend.
resource "aws_ce_anomaly_subscription" "daily" {
  name      = "Default-Services-Subscription"
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.services.arn,
    aws_ce_anomaly_monitor.sandbox.arn,
  ]

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [tostring(var.cost_anomaly_threshold_usd)]
    }
  }

  subscriber {
    type    = "EMAIL"
    address = var.notification_email
  }
}
