
variable "create" {
  description = "Indicates we should create a detector within the region"
  type        = bool
  default     = false
}

variable "detectors" {
  description = "The configuration for the GuardDuty detectors"
  type = map(object({
    name = string
    # The name of the detector
    auto_enable = optional(string, "NONE")
    # The frequency of finding publishing
    additional_configuration = optional(map(object({
      name = optional(string, "NONE")
      auto_enable = optional(string, "NONE")
      # The status of the additional configuration
    })), {})
  }))
  default = {
    s3 = {
      auto_enable = "NONE"
      name        = "S3_DATA_EVENTS"
    }
    eks = {
      auto_enable = "ALL"
      name        = "EKS_AUDIT_LOGS"
    }
    eks_runtime_monitoring = {
      # EKS_RUNTIME_MONITORING is deprecated and should thus be explicitly disabled
      auto_enable = "NONE"
      name        = "EKS_RUNTIME_MONITORING"
      additional_configuration = {
        "EKS_ADDON_MANAGEMENT" = {
          auto_enable = "NONE"
        }
      }
    }
    runtime_monitoring = {
      auto_enable = "NONE"
      name        = "RUNTIME_MONITORING"
      additional_configuration = {
        "EKS_ADDON_MANAGEMENT" = {
          name = "EKS_ADDON_MANAGEMENT"
          auto_enable = "NONE"
        }
        "ECS_FARGATE_AGENT_MANAGEMENT" = {
          name = "ECS_FARGATE_AGENT_MANAGEMENT"
          auto_enable = "NONE"
        }
        "EC2_AGENT_MANAGEMENT" = {
          name = "EC2_AGENT_MANAGEMENT"
          auto_enable = "NONE"
        }
      }
    }
    malware = {
      auto_enable = "NONE"
      name        = "EBS_MALWARE_PROTECTION"
    }
    rds = {
      auto_enable = "NONE"
      name        = "RDS_LOGIN_EVENTS"
    }
    lambda = {
      auto_enable = "NONE"
      name        = "LAMBDA_NETWORK_LOGS"
    }
  }
}

variable "auto_enable_mode" {
  description = "Indicates whether to auto-enable the AWS GuardDuty service in all accounts"
  type        = string
  default     = "ALL"

  validation {
    condition     = var.auto_enable_mode == "ALL" || var.auto_enable_mode == "NEW" || var.auto_enable_mode == "NONE"
    error_message = "auto_enable_mode must be ALL, NEW or NONE"
  }
}

variable "finding_publishing_frequency" {
  description = "The frequency of finding publishing"
  type        = string
  default     = "FIFTEEN_MINUTES"
}

variable "guardduty_detector_id" {
  description = "Used when not creating a new detector"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}
