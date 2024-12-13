
locals {
  ## Determine if the macie service is managed by the landing zone
  macie_managed = var.macie != null
}

## Provision the stackset to enable the macie service across all the accounts
module "macie" {
  count   = local.macie_managed ? 1 : 0
  source  = "appvia/stackset/aws"
  version = "0.1.6"

  name             = try(var.macie.stackset_name, null)
  description      = "Configuration for the AWS macie service, configured by the landing zone"
  exclude_accounts = try(var.macie.exclude_accounts, null)
  region           = var.region
  tags             = var.tags

  template = templatefile("${path.module}/assets/cloudformation/macie.yaml", {
    frequency = var.macie.frequency
    status    = var.macie.enable ? "ENABLED" : "DISABLED"
  })
}
