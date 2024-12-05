#
## Related to organizational configuration
#

## Provision one or more organization managed rules for the config service
resource "aws_config_organization_managed_rule" "current" {
  for_each = var.config.managed_rules

  description          = each.value.description
  input_parameters     = each.value.input_parameters
  name                 = each.key
  resource_id_scope    = each.value.resource_id_scope
  resource_types_scope = each.value.resource_types_scope
  rule_identifier      = each.value.rule_identifier
}
