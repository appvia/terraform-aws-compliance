
## Find the current region
data "aws_region" "current" {}

# Get the mgmt account id via the Organization
data "aws_organizations_organization" "this" {}
