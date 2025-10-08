
## Find the current region
data "aws_region" "current" {}

# Get the mgmt account id via the Organization
data "aws_organizations_organization" "this" {}
# data "aws_organizations_organizational_unit_descendant_accounts" "this" {
#   parent_id = data.aws_organizations_organization.this.roots[0].id
# }

