
locals {
  ## The current region
  region = data.aws_region.current.region

  ## Tag applied to all resources
  tags = merge(var.tags, {})
}
