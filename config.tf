
## Provision and distribute the stacksets to the appropriate accounts for aws config rules.
module "config_rule_groups" {
  for_each = var.config.rule_groups
  source   = "appvia/stackset/aws"
  version  = "0.2.3"

  name                 = format("%s%s", var.config.stackset_name_prefix, lower(each.key))
  description          = format("Used to configure and distribute the AWS Config rules for %s", each.key)
  call_as              = "DELEGATED_ADMIN"
  enabled_regions      = try(each.value.enabled_regions, null)
  exclude_accounts     = each.value.exclude_accounts
  organizational_units = each.value.associations
  accounts             = [local.mgmt_account_id]
  permission_model     = "SERVICE_MANAGED"
  tags                 = local.tags

  template = templatefile("${path.module}/assets/cloudformation/config.yaml", {
    "description"     = each.value.description
    "rule_group_name" = each.key
    "rules"           = each.value.rules
  })
}

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
}

resource "aws_config_configuration_recorder" "mgmt_config_recorder" {
  name     = "appvia-lz-mgmt-recorder"
  role_arn = aws_iam_role.mgmt_config_recorder_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
    resource_types                = null
    exclusion_by_resource_types {
      resource_types = []
    }
    recording_strategy {
      use_only = "ALL_SUPPORTED_RESOURCE_TYPES"
    }
  }

  recording_mode {
    recording_frequency     = "CONTINUOUS"
  }
}

#####

# rather than creating a new bucket, we use the existing bucket from the logging account created by Control Tower
#   in the format "aws-controltower-logs-<logarchive account id>-<home region>".
#   The S3 bucket created by ControlTower has a resource policy that allows write to bucket by AWS Config as a service principle.
#  Need just the name of the bucket not the bucket arn

# need to reuse the SNS topic already created by Control Tower in the audit account
#   in the format "arn:aws:sns:eu-west-1:699561668334:aws-controltower-AllConfigNotifications"
#  Need the ARN of the topic.
data "aws_sns_topic" "control_tower_config_delivery_sns_topic" {
  name = "aws-controltower-AllConfigNotifications"
}

resource "aws_config_delivery_channel" "foo" {
  name           = "appvia-lz-mgmt-delivery-channel"
  s3_bucket_name = format("aws-controltower-logs-%s-%s", local.logarchive_account_id, local.region)
  s3_key_prefix  = local.organization_id
  sns_topic_arn  = data.aws_sns_topic.control_tower_config_delivery_sns_topic.arn

  snapshot_delivery_properties {
    # default is TwentyFour_Hours; but this is the mgmt account
    delivery_frequency = "Three_Hours"
  }
  depends_on = [aws_config_configuration_recorder.mgmt_config_recorder]
}


# {
#     "ConfigurationRecorders": [
#         {
#             "name": "aws-controltower-BaselineConfigRecorder",
#             "roleARN": "arn:aws:iam::856708425195:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig",
#             "recordingGroup": {
#                 "allSupported": true,
#                 "includeGlobalResourceTypes": true,
#                 "resourceTypes": [],
#                 "exclusionByResourceTypes": {
#                     "resourceTypes": []
#                 },
#                 "recordingStrategy": {
#                     "useOnly": "ALL_SUPPORTED_RESOURCE_TYPES"
#                 }
#             },
#             "recordingMode": {
#                 "recordingFrequency": "CONTINUOUS",
#                 "recordingModeOverrides": []
#             }
#         }
#     ]
# }

# AWS_PROFILE=appvia-lz-network aws configservice describe-delivery-channels
# {
#     "DeliveryChannels": [
#         {
#             "name": "aws-controltower-BaselineConfigDeliveryChannel",
#             "s3BucketName": "aws-controltower-logs-144403604133-eu-west-1",
#             "s3KeyPrefix": "o-8ec371lgji",
#             "snsTopicARN": "arn:aws:sns:eu-west-1:699561668334:aws-controltower-AllConfigNotifications",
#             "configSnapshotDeliveryProperties": {
#                 "deliveryFrequency": "TwentyFour_Hours"
#             }
#         }
#     ]
# }
