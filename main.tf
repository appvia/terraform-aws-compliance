## AWS Config

## Provision and distribute the stacksets to the appropriate accounts for aws config rules.
module "config_rule_groups" {
  for_each = var.config.rule_groups
  source   = "appvia/stackset/aws"
  version  = "0.1.10"

  name                 = format("%s%s", var.config.stackset_name_prefix, lower(each.key))
  description          = format("Used to configure and distribute the AWS Config rules for %s", each.key)
  call_as              = "DELEGATED_ADMIN"
  enabled_regions      = try(each.value.enabled_regions, null)
  exclude_accounts     = each.value.exclude_accounts
  organizational_units = each.value.associations
  permission_model     = "SERVICE_MANAGED"
  tags                 = local.tags

  template = templatefile("${path.module}/assets/cloudformation/config.yaml", {
    "description"     = each.value.description
    "rule_group_name" = each.key
    "rules"           = each.value.rules
  })
}

## AWS Macie

## Provision the stackset to enable the macie service across all the accounts
module "macie" {
  count   = local.macie_enabled ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.10"

  name             = try(var.macie.stackset_name, null)
  description      = "Configuration for the AWS macie service, configured by the landing zone"
  exclude_accounts = try(var.macie.exclude_accounts, null)
  region           = var.region
  tags             = local.tags

  template = templatefile("${path.module}/assets/cloudformation/macie.yaml", {
    frequency = var.macie.frequency
    status    = var.macie.enable ? "ENABLED" : "DISABLED"
  })
}

## AWS Access Analyzer

## Provision the unused access analyzer
resource "aws_accessanalyzer_analyzer" "unused_access" {
  count = local.analyzer_enabled && try(var.access_analyzer.enable_unused_analyzer, false) ? 1 : 0

  analyzer_name = var.access_analyzer.unused_analyzer_name
  type          = "ORGANIZATION_UNUSED_ACCESS"
  configuration {
    unused_access {
      unused_access_age = var.access_analyzer.unused_access_age
    }
  }
}

## AWS Security Hub

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

  name        = each.key
  description = each.value.description

  configuration_policy {
    service_enabled = each.value.enable

    enabled_standard_arns = [
      for standard in each.value.policy.standard_arns : local.standards_subscription[standard]
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

  policy_id = aws_securityhub_configuration_policy.current[each.value.policy].id
  target_id = each.value.target_id

  depends_on = [aws_securityhub_configuration_policy.current]
}
