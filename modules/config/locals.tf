
locals {
  ## The current region
  region = data.aws_region.current.region

  ## Tag applied to all resources
  tags = merge(var.tags, {})

  # using Organization - resolve the mgmt account id (it's only ever the one account in the Management OU)
  logarchive_account_id = var.logarchive_account_id
  organization_id = data.aws_organizations_organization.this.id
}
