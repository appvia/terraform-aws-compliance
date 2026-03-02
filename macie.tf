
locals {
  ## Determine if the macie service is managed by the landing zone
  macie_enabled = try(var.macie.enable, false)
}

## Provision the stackset to enable the macie service across all the accounts
module "macie" {
  count   = local.macie_enabled ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.2.9"

  name             = try(var.macie.stackset_name, "lz-macie-configuration")
  description      = "Configuration for the AWS macie service, configured by the landing zone"
  call_as          = "DELEGATED_ADMIN"
  exclude_accounts = try(var.macie.exclude_accounts, null)
  permission_model = "SERVICE_MANAGED"
  region           = var.region
  tags             = local.tags

  template = templatefile("${path.module}/assets/cloudformation/macie.yaml", {
    frequency = var.macie.frequency
    status    = var.macie.enable ? "ENABLED" : "DISABLED"
  })
}
