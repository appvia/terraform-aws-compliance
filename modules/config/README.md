<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_config"></a> [config](#input\_config) | Configuration for the securityhub organization managed rules | <pre>object({<br/>    stackset_name_prefix = optional(string, "lza-config-")<br/><br/>    # The prefix added to the stacksets<br/>    rule_groups = optional(map(object({<br/>      associations = list(string)<br/>      # List of organizational units to deploy the managed rules<br/>      description = string<br/>      # Description for the rule group<br/>      enabled_regions = optional(list(string), null)<br/>      # List of regions to enable these rules<br/>      exclude_accounts = optional(list(string), null)<br/>      # The list of accounts to exclude from the organization managed rule<br/>      rules = map(object({<br/>        description = string<br/>        # The description of the organization managed rules<br/>        identifier = string<br/>        # The identifier of the organization managed rule<br/>        inputs = optional(map(string), {})<br/>        # The identifier of the organization managed rule scope<br/>        resource_types = list(string)<br/>        # The list of resource types to scope the organization managed rule<br/>        max_execution_frequency = optional(string, null)<br/>        # The max_execution_frequency of the rule<br/>      }))<br/>    })), {})<br/>    # The configuration for the securityhub organization managed rules<br/>  })</pre> | n/a | yes |
| <a name="input_control_tower_sns_topic_arn"></a> [control\_tower\_sns\_topic\_arn](#input\_control\_tower\_sns\_topic\_arn) | The ARN of the SNS topic created by Control Tower for AWS notifications | `string` | n/a | yes |
| <a name="input_home_region"></a> [home\_region](#input\_home\_region) | The home Region in which Control Tower created the Config S3 buckiet (namely, in logarchive account | `string` | n/a | yes |
| <a name="input_logarchive_account_id"></a> [logarchive\_account\_id](#input\_logarchive\_account\_id) | The AWS account id for the logarchive account created by Control Tower | `string` | n/a | yes |
| <a name="input_config_retention_in_days"></a> [config\_retention\_in\_days](#input\_config\_retention\_in\_days) | The number of days to store config historical data (defaults to one year) | `number` | `366` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aws_config_delivery_channel_id"></a> [aws\_config\_delivery\_channel\_id](#output\_aws\_config\_delivery\_channel\_id) | The ID of Config delivery channel |
| <a name="output_aws_config_recorder_id"></a> [aws\_config\_recorder\_id](#output\_aws\_config\_recorder\_id) | The ID of Config recorder |
<!-- END_TF_DOCS -->
