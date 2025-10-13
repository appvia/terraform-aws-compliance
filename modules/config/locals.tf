
locals {
  ## The current region
  region = data.aws_region.current.region

  ## Tag applied to all resources
  tags = merge(var.tags, {})
 
  ## used to resovle the target S3 bucket for Config data
  logarchive_account_id = var.logarchive_account_id

  # capture the Organization - to then resolve the mgmt account id in locals
  organization_id       = data.aws_organizations_organization.this.id
}
