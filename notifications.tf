#
## Related to Security Hub notifications
#
locals {
  ## The pattern to match the security hub findings
  securityhub_event_pattern = jsonencode({
    detail = {
      findings = {
        Compliance = {
          Status = ["FAILED"]
        },
        RecordState = ["ACTIVE"],
        Severity = {
          Label = var.securityhub.notifications.severities
        },
        Workflow = {
          Status = ["NEW"]
        }
      }
    },
    detail-type = ["Security Hub Findings - Imported"],
    source      = ["aws.securityhub"]
  })

  ## Indicates if the notifications for slack are enabled
  enable_slack_notifications = var.notifications.slack != null
  ## Indicates if the notifications for teams are enabled
  enable_teams_notifications = var.notifications.teams != null

  ## The configuration for the slack notification
  slack = local.enable_slack_notifications ? {
    lambda_name = try(var.notifications.slack.lambda_name, null)
    webhook_url = try(var.notifications.slack.webhook_url, null)
  } : null

  teams = local.enable_teams_notifications ? {
    lambda_name = try(var.notifications.teams.lambda_name, null)
    webhook_url = try(var.notifications.teams.webhook_url, null)
  } : null

  email = {
    addresses = try(var.notifications.email.addresses, [])
  }
}

## Provision the notifications to forward the security hub findings to the messaging channel
module "securityhub_notifications" {
  count   = var.securityhub.notifications.enable ? 1 : 0
  source  = "appvia/notify/aws"
  version = "0.0.5"

  allowed_aws_services           = ["events.amazonaws.com", "lambda.amazonaws.com"]
  cloudwatch_log_group_retention = 1
  email                          = local.email
  slack                          = local.slack
  sns_topic_name                 = var.securityhub.notifications.sns_topic_queue_name
  tags                           = local.tags
  teams                          = local.teams
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = var.securityhub.notifications.enable ? 1 : 0

  name          = var.securityhub.notifications.eventbridge_rule_name
  description   = format("Capture Security Hub findings and publish to the SNS topic: %s", var.securityhub.notifications.sns_topic_queue_name)
  event_pattern = local.securityhub_event_pattern
  tags          = local.tags

  depends_on = [
    module.securityhub_notifications
  ]
}

## Add the SNS Topic as a Target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "securityhub_findings_target" {
  count = var.securityhub.notifications.enable ? 1 : 0

  rule      = aws_cloudwatch_event_rule.securityhub_findings[0].name
  target_id = "sns-target"
  arn       = module.securityhub_notifications[0].sns_topic_arn
}
