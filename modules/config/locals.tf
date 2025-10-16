
locals {
  ## The current region
  region = data.aws_region.current.region

  ## Tag applied to all resources
  tags = merge(var.tags, {})

  ## used to resovle the target S3 bucket for Config data
  logarchive_account_id = var.logarchive_account_id

  home_region = var.home_region
}
