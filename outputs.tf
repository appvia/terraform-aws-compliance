
output "securityhub_policy_configurations" {
  description = "A map of all the policies to the central configuration arns"
  value       = local.policy_standards
}

output "securityhub_policy_associations" {
  description = "A map of policy associations by policy name"
  value       = local.policy_associations_by_policy
}

output "inspector_resource_types" {
  description = "A list of resources type to enable for inspector"
  value       = try(local.inspector_resources_types, [])
}
