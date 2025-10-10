## the mgmt account is not configured by Control Tower for AWS
# Create a recorder in mgmt account
# Create and associate a delivery channel - that delivery channel is to the logarchive S3 bucket
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
  name               = "appvia-lz-mgmt-awsconfig-recorder-role"
  assume_role_policy = data.aws_iam_policy_document.mgmt_config_recorder_policy.json

  tags = local.tags

  provider = aws.mgmt
}

#  this AWS resources has no tags attribute
resource "aws_config_configuration_recorder" "mgmt_config_recorder" {

  name     = "appvia-lz-mgmt-recorder"
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

  provider = aws.mgmt
}

# rather than creating a new bucket, we use the existing bucket from the logging account created by Control Tower
#   in the format "aws-controltower-logs-<logarchive account id>-<home region>".
#   The S3 bucket created by ControlTower has a resource policy that allows write to bucket by AWS Config as a service principle.
#  Need just the name of the bucket not the bucket arn

# need to reuse the SNS topic already created by Control Tower in the audit account
#   in the format "arn:aws:sns:eu-west-1:699561668334:aws-controltower-AllConfigNotifications"
#  Need the ARN of the topic.
data "aws_sns_topic" "control_tower_config_delivery_sns_topic" {
  name = "aws-controltower-AllConfigNotifications"

  provider = aws.audit
}

#  this AWS resources has no tags attribute
resource "aws_config_delivery_channel" "mgmt_config_delivery_channel" {
  name           = "appvia-lz-mgmt-delivery-channel"
  s3_bucket_name = format("aws-controltower-logs-%s-%s", local.logarchive_account_id, local.region)
  s3_key_prefix  = local.organization_id
  sns_topic_arn  = data.aws_sns_topic.control_tower_config_delivery_sns_topic.arn

  snapshot_delivery_properties {
    # default is TwentyFour_Hours; but this is the mgmt account
    delivery_frequency = "Three_Hours"
  }

  depends_on = [aws_config_configuration_recorder.mgmt_config_recorder]

  provider = aws.mgmt
}

resource "aws_config_retention_configuration" "mgmt_config_retention" {
  retention_period_in_days = var.config_retention_in_days

  provider = aws.mgmt
}
