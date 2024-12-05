
locals {
  ## The current region
  region = data.aws_region.current.name

  ## The subscription for the standards
  standards_subscription = {
    aws_foundational_best_practices = "arn:aws:securityhub:${local.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
    cis_v120                        = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
    cis_v140                        = "arn:aws:securityhub:${local.region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
    nist_sp_800_53_rev5             = "arn:aws:securityhub:${local.region}::standards/nist-800-53/v/5.0.0"
    pci_dss                         = "arn:aws:securityhub:${local.region}::standards/pci-dss/v/3.2.1"
  }

  ## A lost of policy associations
  policy_associations_all = flatten([
    for policy_name, policy in var.securityhub.policies : [
      for association in policy.associations : {
        key             = format("%s-%s", policy_name, coalesce(association.account_id, association.organization_unit))
        policy_name     = policy_name
        account_id      = association.account_id
        organization_id = association.organization_unit
      }
    ] if(policy.associations) > 0
  ])

  ## A map of policy associations by policy name
  policy_associations_by_policy = {
    for association in local.policy_associations_all : association.policy_name => association
  }
}
