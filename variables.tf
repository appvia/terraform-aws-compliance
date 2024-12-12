
variable "config" {
  description = "Configuration for the securityhub organization managed rules"
  type = object({
    managed_rules = optional(map(object({
      description = string
      # The description of the organization managed rules
      rule_identifier = string
      # The identifier of the organization managed rule
      excluded_accounts = optional(list(string), null)
      # The list of accounts to exclude from the organization managed rule
      input_parameters = optional(string, null)
      # A string in JSON format that is passed to the AWS Config Rule Lambda Function
      rule_identifier_scope = string
      # The identifier of the organization managed rule scope
      resource_id_scope = optional(string, null)
      # The identifier of the organization managed rule scope
      resource_types_scope = optional(list(string), null)
      # The list of resource types to scope the organization managed rule
    })), {})
    # The configuration for the securityhub organization managed rules
  })
  default = {
    managed_rules = {}
  }
}

variable "guardduty" {
  description = "Oragnizational configuration for the AWS GuardDuty service"
  type = object({
    create = optional(bool, false)
    # A flag indicating if GuardDuty should be created
    finding_publishing_frequency = optional(string, "FIFTEEN_MINUTES")
    # The frequency of finding publishing
    detectors = optional(list(object({
      name = string
      # The name of the detector
      enable = optional(bool, true)
      # The frequency of finding publishing
      additional_configuration = optional(list(object({
        name = string
        # The name of the additional configuration
        enable = optional(bool, true)
        # The status of the additional configuration
      })), [])
    })), [])
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
