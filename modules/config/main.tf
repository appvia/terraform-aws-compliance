## the mgmt account is not configured by Control Tower, for AWS Config
# Create a recorder in mgmt account
# Create and associate a delivery channel - that delivery channel is to existing logarchive S3 bucket and SNS topic created by Control Tower
data "aws_iam_policy_document" "mgmt_config_recorder_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "mgmt_config_recorder_role" {
  name               = format("lz-mgmt-awsconfig-recorder-%s-role", local.region)
  assume_role_policy = data.aws_iam_policy_document.mgmt_config_recorder_policy.json

  tags = local.tags
}

#  this AWS resources has no tags attribute
resource "aws_config_configuration_recorder" "mgmt_config_recorder" {

  name     = "lz-mgmt-recorder"
  role_arn = aws_iam_role.mgmt_config_recorder_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
    resource_types                = null
    #  if all_supported is true, must be specify any exclusions
    # exclusion_by_resource_types {
    #   resource_types = []
    # }
    recording_strategy {
      use_only = "ALL_SUPPORTED_RESOURCE_TYPES"
    }
  }

  recording_mode {
    recording_frequency = "CONTINUOUS"
    # recording_mode_override {}
  }
}

#  this AWS resources has no tags attribute
resource "aws_config_delivery_channel" "mgmt_config_delivery_channel" {
  name           = "lz-mgmt-delivery-channel"
  s3_bucket_name = format("aws-controltower-logs-%s-%s", local.logarchive_account_id, local.home_region)
  s3_key_prefix  = local.organization_id
  sns_topic_arn  = var.control_tower_sns_topic_arn

  snapshot_delivery_properties {
    # default is TwentyFour_Hours; but this is the mgmt account
    delivery_frequency = "Three_Hours"
  }

  depends_on = [aws_config_configuration_recorder.mgmt_config_recorder]
}

resource "aws_config_retention_configuration" "mgmt_config_retention" {
  retention_period_in_days = var.config_retention_in_days
}
