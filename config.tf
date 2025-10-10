
## Provision and distribute the stacksets to the appropriate accounts for aws config rules.
module "config_rule_groups" {
  for_each = var.config.rule_groups
  source   = "appvia/stackset/aws"
  version  = "0.2.3"

  name                 = format("%s%s", var.config.stackset_name_prefix, lower(each.key))
  description          = format("Used to configure and distribute the AWS Config rules for %s", each.key)
  call_as              = "DELEGATED_ADMIN"
  enabled_regions      = try(each.value.enabled_regions, null)
  exclude_accounts     = each.value.exclude_accounts
  organizational_units = each.value.associations
  accounts             = [local.mgmt_account_id]
  permission_model     = "SERVICE_MANAGED"
  tags                 = local.tags

  template = templatefile("${path.module}/assets/cloudformation/config.yaml", {
    "description"     = each.value.description
    "rule_group_name" = each.key
    "rules"           = each.value.rules
  })
}
