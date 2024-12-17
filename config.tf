
## Provision and distribute the stacksets to the appropriate accounts
module "config_rule_groups" {
  for_each = var.config.rule_groups
  source   = "appvia/stackset/aws"
  version  = "0.1.7"

  name                 = format("%s%s", var.config.stackset_name_prefix, lower(each.key))
  description          = format("Used to configure and distribute the AWS Config rules for %s", each.key)
  call_as              = "DELEGATED_ADMIN"
  enabled_regions      = try(each.value.enabled_regions, null)
  exclude_accounts     = each.value.exclude_accounts
  organizational_units = each.value.associations
  permission_model     = "SERVICE_MANAGED"
  tags                 = var.tags

  template = templatefile("${path.module}/assets/cloudformation/config.yaml", {
    "description"   = each.value.description
    "name"          = each.key
    "resource_name" = format("%s%s", upper(replace(each.key, "-", "")), upper(each.rule.name))
    "rules"         = each.value.rules
  })
}
