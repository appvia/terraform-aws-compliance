<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.audit_eu_west_2"></a> [aws.audit\_eu\_west\_2](#provider\_aws.audit\_eu\_west\_2) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compliance"></a> [compliance](#module\_compliance) | ../.. | n/a |
| <a name="module_guardduty_home"></a> [guardduty\_home](#module\_guardduty\_home) | ../../modules/guardduty | n/a |
| <a name="module_guardduty_us_east_1"></a> [guardduty\_us\_east\_1](#module\_guardduty\_us\_east\_1) | ../../modules/guardduty | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/guardduty_detector) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_securityhub_policy_configurations"></a> [securityhub\_policy\_configurations](#output\_securityhub\_policy\_configurations) | A map of all the policies to the central configuration arns |
<!-- END_TF_DOCS -->