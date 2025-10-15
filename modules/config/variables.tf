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
