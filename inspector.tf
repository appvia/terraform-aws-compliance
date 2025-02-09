
locals {
  ## A list of resources type to enable for inspector
  inspector_resources_types = compact([
    var.inspector.enable_ec2_scan ? "EC2" : null,
    var.inspector.enable_ecr_scan ? "ECR" : null,
    var.inspector.enable_lambda_code_scan ? "LAMBDA_CODE" : null,
    var.inspector.enable_lambda_scan ? "LAMBDA" : null,
  ])
}

resource "aws_inspector2_enabler" "inspector" {
  count = var.inspector.enable ? 1 : 0

  account_ids    = [var.inspector.account_id]
  resource_types = local.inspector_resources_types
}

## All new accounts will have inspector enabled for the following resource types, any
## existing accounts will need to be enabled manually via the aws_inspector2_member_association
resource "aws_inspector2_organization_configuration" "auto_enable_inspector_new_accounts" {
  auto_enable {
    ec2         = var.inspector.enable_ec2_scan
    ecr         = var.inspector.enable_ecr_scan
    lambda      = var.inspector.enable_lambda_scan
    lambda_code = var.inspector.enable_lambda_code_scan
  }
}

