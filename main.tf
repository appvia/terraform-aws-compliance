
## Provision a securityhub aggregator in the account
resource "aws_securityhub_finding_aggregator" "current" {
  count = var.securityhub.aggregator.create ? 1 : 0

  linking_mode      = var.securityhub.aggregator.linking_mode
  specified_regions = var.securityhub.aggregator.specified_regions
}

## Provision the organization configuration
resource "aws_securityhub_organization_configuration" "current" {
  auto_enable           = var.securityhub.configuration.auto_enable
  auto_enable_standards = var.securityhub.configuration.auto_enable_standards

  organization_configuration {
    configuration_type = var.securityhub.configuration.organization_configuration.configuration_type
  }

  depends_on = [
    aws_securityhub_finding_aggregator.current,
  ]
}

## Provision one or more configuration policies for the security hub
resource "aws_securityhub_configuration_policy" "current" {
  for_each = var.securityhub.policies

  name        = each.value.name
  description = each.value.description

  configuration_policy {
    service_enabled = each.value.service_enable

    enabled_standard_arns = [
      for standard in each.value.policy.standard_arns : local.standards_subscription[standard].arn
    ]

    security_controls_configuration {
      disabled_control_identifiers = each.value.policy.controls.disabled

      dynamic "security_control_custom_parameter" {
        for_each = each.value.policy.controls.custom_parameter != null ? each.value.policy.controls.custom_parameter : []

        content {
          security_control_id = security_control_custom_parameter.value.security_control_id

          parameter {
            name       = security_control_custom_parameter.value.parameter.name
            value_type = security_control_custom_parameter.value.parameter.value_type
          }
        }
      }
    }
  }

  depends_on = [aws_securityhub_organization_configuration.current]
}

## Associate a security hub policy with an account or organizational unit
resource "aws_securityhub_configuration_policy_association" "current" {
  for_each = local.policy_associations_by_policy

  policy_id = aws_securityhub_configuration_policy.current[each.value.policy_name].id
  target_id = coalesce(each.value.account_id, each.value.organization_id)

  depends_on = [aws_securityhub_configuration_policy.current]
}
