
locals {
  ## The current region
  region = data.aws_region.current.name
  ## Tag applied to all resources
  tags = merge(var.tags, {})

  # using Organization - resolve the mgmt account id (it's only ever the one account in the Management OU)
  mgmt_account_id = data.aws_organizations_organization.this.master_account_id
}
