

## Provision the detector for the guardduty if required
resource "aws_guardduty_detector" "guardduty" {
  count = local.create ? 1 : 0

  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.tags
}

## Provision a guardduty detector for this account if required
resource "aws_guardduty_organization_configuration" "guardduty" {
  auto_enable_organization_members = var.auto_enable_mode
  detector_id                      = local.guardduty_detector_id

  depends_on = [
    aws_guardduty_detector.guardduty,
  ]
}

## Provision the guardduty detectors
resource "aws_guardduty_organization_configuration_feature" "this" {
  for_each = var.detectors

  auto_enable = each.value.auto_enable
  detector_id = local.guardduty_detector_id
  name        = each.value.name

  dynamic "additional_configuration" {
    for_each = try(each.value.ecs_additional_configuration, {})
    content {
      auto_enable = additional_configuration.value.auto_enable
      name        = additional_configuration.key
    }
  }

  dynamic "additional_configuration" {
    for_each = try(each.value.ec2_additional_configuration, {})
    content {
      auto_enable = additional_configuration.value.auto_enable
      name        = additional_configuration.key
    }
  }

  dynamic "additional_configuration" {
    for_each = try(each.value.eks_additional_configuration, {})
    content {
      auto_enable = additional_configuration.value.auto_enable
      name        = additional_configuration.key
    }
  }

  depends_on = [
    aws_guardduty_organization_configuration.guardduty,
  ]
}
