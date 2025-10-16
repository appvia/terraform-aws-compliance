variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
  default = {
  }
}

variable "logarchive_account_id" {
  description = "The AWS account id for the logarchive account created by Control Tower"
  type        = string
}

variable "config_retention_in_days" {
  description = "The number of days to store config historical data (defaults to one year)"
  type        = number
  default     = 366
}

variable "control_tower_sns_topic_arn" {
  description = "The ARN of the SNS topic created by Control Tower for AWS notifications"
  type        = string
}

variable "home_region" {
  description = "The home Region in which Control Tower created the Config S3 buckiet (namely, in logarchive account"
  type        = string
  validation {
    condition     = can(regex("^\\D\\D-\\D+-\\d$", var.home_region))
    error_message = "Region must be in the form xx-xxxx-x, e.g., eu-west-1"
  }
}

variable "config" {
  description = "Configuration for the securityhub organization managed rules"
  type = object({
    stackset_name_prefix = optional(string, "lza-config-")

    # The prefix added to the stacksets
    rule_groups = optional(map(object({
      associations = list(string)
      # List of organizational units to deploy the managed rules
      description = string
      # Description for the rule group
      enabled_regions = optional(list(string), null)
      # List of regions to enable these rules
      exclude_accounts = optional(list(string), null)
      # The list of accounts to exclude from the organization managed rule
      rules = map(object({
        description = string
        # The description of the organization managed rules
        identifier = string
        # The identifier of the organization managed rule
        inputs = optional(map(string), {})
        # The identifier of the organization managed rule scope
        resource_types = list(string)
        # The list of resource types to scope the organization managed rule
        max_execution_frequency = optional(string, null)
        # The max_execution_frequency of the rule
      }))
    })), {})
    # The configuration for the securityhub organization managed rules
  })
  default = {
    rule_groups = {}
  }
}
