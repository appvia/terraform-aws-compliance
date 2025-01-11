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
}

## Provision the notifications to forward the security hub findings to the messaging channel
module "securityhub_notifications" {
  count   = var.securityhub.notifications.enable ? 1 : 0
  source  = "appvia/notifications/aws"
  version = "1.1.0"

  allowed_aws_services           = ["events.amazonaws.com", "lambda.amazonaws.com"]
  cloudwatch_log_group_retention = 1
  create_sns_topic               = true
  email                          = local.email
  enable_slack                   = local.enable_teams_notifications
  enable_teams                   = local.enable_slack_notifications
  slack                          = local.slack
  sns_topic_name                 = var.securityhub.notifications.sns_topic_queue_name
  tags                           = local.tags
  teams                          = local.teams
}

## Provision the event bridge rule to capture security hub findings, of a specific severities
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = var.securityhub.notifications.enable ? 1 : 0

  name          = var.securityhub.notifications.eventbridge_rule_name
  description   = format("Capture Security Hub findings and publish to the SNS topic: %s", try(module.securityhub_notifications[0].sns_topic_name, null))
  event_pattern = local.securityhub_event_pattern
  tags          = local.tags
}

## Add the SNS Topic as a Target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "securityhub_findings_target" {
  count = var.securityhub.notifications.enable ? 1 : 0

  rule      = aws_cloudwatch_event_rule.securityhub_findings[0].name
  target_id = "sns-target"
  arn       = module.securityhub_notifications[0].sns_topic_arn
}
