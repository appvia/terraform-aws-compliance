
locals {
  ## Determine if the macie service is managed by the landing zone
  macie_enabled = var.macie != null
}

## Provision the stackset to enable the macie service across all the accounts
module "macie" {
  count   = local.macie_enabled ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.2.4"

  name             = try(var.macie.stackset_name, null)
  description      = "Configuration for the AWS macie service, configured by the landing zone"
  exclude_accounts = try(var.macie.exclude_accounts, null)
  region           = var.region
  tags             = local.tags

  template = templatefile("${path.module}/assets/cloudformation/macie.yaml", {
    frequency = var.macie.frequency
    status    = var.macie.enable ? "ENABLED" : "DISABLED"
  })
}
