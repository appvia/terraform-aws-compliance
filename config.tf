
## Provision and distribute the stacksets to the appropriate accounts
module "config_rule_groups" {
  for_each = var.config.rule_groups
  source   = "appvia/stackset/aws"
  version  = "0.1.6"

  name                 = format("%s-%s", var.config.stackset_name_prefix, lower(each.key))
  description          = format("Used to configure and distribute the AWS Config rules for %s", each.key)
  enabled_regions      = try(each.value.enabled_regions, null)
  exclude_accounts     = each.value.exclude_accounts
  organizational_units = each.value.associations
  tags                 = var.tags

  template = templatefile("${path.module}/assets/cloudformation/config.yaml", {
    "name"        = each.key
    "descruption" = each.value.description
    "rules"       = each.value.rules
  })
}
