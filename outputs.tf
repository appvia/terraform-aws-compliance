
output "securityhub_policy_configurations" {
  description = "A map of all the policies to the central configuration arns"
  value       = local.policy_standards
}
