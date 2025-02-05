
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

variable "inspector" {
  description = "Organizational configuration for the AWS Inspector service"
  type = object({
    account_id = optional(string, null)
    # The delegated administrator account ID for the AWS Inspector service
    enable = optional(bool, false)
    # Indicates whether to enable the AWS Inspector service
    enable_ec2_scan = optional(bool, false)
    # Indicates whether to enable the AWS Inspector service for EC2 instances
    enable_ecr_scan = optional(bool, false)
    # Indicates whether to enable the AWS Inspector service for ECR repositories
    enable_lambda_scan = optional(bool, false)
    # Indicates whether to enable the AWS Inspector service for Lambda functions
    enable_lambda_code_scan = optional(bool, false)
    # Indicates whether to enable the AWS Inspector service for Lambda code
  })
  default = {
    enable = false
  }
}

variable "notifications" {
  description = "Configuration for the notifications"
  type = object({
    email = optional(object({
      addresses = optional(list(string), [])
    }), null)
    slack = optional(object({
      lamdba_name = optional(string, "lz-securityhub-all-notifications-slack")
      webhook_url = string
    }), null)
    teams = optional(object({
      lamdba_name = optional(string, "lz-securityhub-all-notifications-teams")
      webhook_url = string
    }), null)
  })
  default = {
    email = {
      addresses = []
    }
    slack = null
    teams = null
  }
}

variable "access_analyzer" {
  description = "Configuration for the AWS Access Analyzer service"
  type = object({
    enable_unused_analyzer = optional(bool, true)
    # Indicates whether to enable the unused AWS Access Analyzer service
    unused_analyzer_name = optional(string, "lza-unused-access-analyzer")
    # The name of the unused AWS Access Analyzer service
    unused_access_age = optional(number, 90)
  })
  default = null
}

variable "macie" {
  description = "Configuration for the AWS Macie service"
  type = object({
    enable = optional(bool, false)
    # Indicates whether to enable the AWS Macie service should be enabled in all accounts
    excluded_accounts = optional(list(string), null)
    # The list of accounts to exclude from the AWS Macie service
    frequency = optional(string, "FIFTEEN_MINUTES")
    # The frequency at which the AWS Macie service should be enabled
    organizational_units = optional(list(string), null)
    # The list of member accounts to associate with the AWS Macie service
    stackset_name = optional(string, "lza-macie-configuration")
  })
  default = null
}

variable "region" {
  description = "The region to deploy the resources"
  type        = string
}

variable "securityhub" {
  description = "Configuration for the securityhub"
  type = object({
    aggregator = optional(object({
      create = optional(bool, false)
      # Indicates whether to create the securityhub
      # Indicates whether to create the aggregator
      linking_mode = optional(string, "ALL_REGIONS")
      # Indicates whether to aggregate findings from all of the available regions
      specified_regions = optional(list(string), null)
      # A list of regions to aggregate findings from when using SPECIFIED_REGIONS linking mode
      }), {
      create            = false
      linking_mode      = "ALL_REGIONS"
      specified_regions = null
      }
    )
    # The configuration for the aggregator
    configuration = optional(object({
      auto_enable = optional(bool, true)
      # Indicates whether to automatically enable Security Hub
      auto_enable_standards = optional(string, "DEFAULT")
      # Indicates whether to automatically enable new controls and standards
      organization_configuration = object({
        configuration_type = optional(string, "CENTRAL")
        # Indicates whether to enable Security Hub as a standalone service or as an organization master
      })
      # The configuration for the organization
      }), {
      auto_enable           = false
      auto_enable_standards = "DEFAULT"
      organization_configuration = {
        configuration_type = "CENTRAL"
      }
    })
    # The configuration for the securityhub
    notifications = optional(object({
      enable = optional(bool, false)
      # Indicates whether to enable the securityhub notifications
      eventbridge_rule_name = optional(string, "lza-securityhub-all-notifications")
      # The name of the event bridge rule
      severities = optional(list(string), ["CRITICAL", "HIGH"])
      # The list of severities to enable the notifications
      sns_topic_queue_name = optional(string, "lza-securityhub-all-notifications")
      # Name of the SNS topic to send the notifications
      }), {
      enable                = false
      eventbridge_rule_name = "lza-securityhub-all-notifications"
      severities            = []
      sns_topic_queue_name  = "lza-securityhub-all-notifications"
    })
    # The configuration for the notifications
    policies = optional(map(object({
      enable = optional(bool, true)
      # Indicates whether the configuration policy is enabled
      description = string
      # The description of the configuration policy
      associations = optional(list(object({
        account_id = optional(string, null)
        # The account ID to associate with the policy
        organization_unit = optional(string, null)
        # The organization unit to associate with the policy
      })), [])
      # The list of associations for the configuration policy
      policy = object({
        enable = optional(bool, true)
        # Indicates whether the configuration policy is enabled
        standard_arns = list(string)
        # The ARNs of the standards to enable
        controls = object({
          disabled = optional(list(string), null)
          # The list of control identifiers to disable
          custom_parameter = optional(list(object({
            security_control_id = string
            # The ID of the security control
            parameter = object({
              name = string
              # The name of the parameter
              value_type = string
              # The type of the parameter
              enum = optional(object({
                value = string
                # The value of the parameter (if the type is ENUM)
              }), null)
            })
            # The parameter for the security control
          })), null)
        })
        # The parameter for the security control
      })
      # The configuration policy
    })), {})
  })
  default = {
    aggregator = {
      create            = false
      linking_mode      = "ALL_REGIONS"
      specified_regions = null
    }
    configuration = {
      auto_enable           = false
      auto_enable_standards = "NONE"
      organization_configuration = {
        configuration_type = "CENTRAL"
      }
    }
    policies = {}
  }
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}
