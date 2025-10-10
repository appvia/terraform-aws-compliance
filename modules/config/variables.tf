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
  default     = 2557
}