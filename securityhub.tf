
locals {
  ## The subscription for the standards
  standards_subscription = {
    aws_foundational_best_practices = "arn:aws:securityhub:${local.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
    cis_v120                        = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    cis_v140                        = "arn:aws:securityhub:${local.region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
    nist_sp_800_53_rev5             = "arn:aws:securityhub:${local.region}::standards/nist-800-53/v/5.0.0"
    pci_dss                         = "arn:aws:securityhub:${local.region}::standards/pci-dss/v/3.2.1"
    warren                          = "arn:aws:securityhub:${local.region}::standards/aws-resource-tagging-standard/v/1.0.0"
  }

  ## A list of policy associations
  policy_associations_all = flatten([
    for policy_name, policy in var.securityhub.policies : [
      for association in policy.associations : {
        account             = association.account_id
        key                 = format("%s-%s", policy_name, coalesce(association.account_id, association.organization_unit))
        organizational_unit = association.organization_unit
        policy_name         = policy_name
        target_id           = coalesce(association.account_id, association.organization_unit)
      }
    ] if length(policy.associations) > 0
  ])

  ## A map of all the policy associations by policy name
  policy_associations_by_policy = {
    for association in local.policy_associations_all : association.key => {
      account            = association.account
      organization_units = association.organizational_unit
      policy_key         = association.key
      policy_name        = association.policy_name
      target_id          = association.target_id
    }
  }

  ## A map of all the policies to the central configuration arns
  policy_standards = {
    for policy in aws_securityhub_configuration_policy.current : policy.name => policy.id
  }
}

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
      # for standard in each.value.policy.standard_arns : local.standards_subscription[standard]
      "arn:aws:securityhub:eu-west-1::standards/aws-resource-tagging-standard/v/1.0.0",
      "arn:aws:securityhub:eu-west-1::standards/aws-foundational-security-best-practices/v/1.0.0",
      "arn:aws:securityhub:eu-west-1::standards/cis-aws-foundations-benchmark/v/1.4.0",
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
  target_id = each.value.target_id

  depends_on = [aws_securityhub_configuration_policy.current]
}
