<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the resources | `map(string)` | n/a | yes |
| <a name="input_auto_enable_mode"></a> [auto\_enable\_mode](#input\_auto\_enable\_mode) | Indicates whether to auto-enable the AWS GuardDuty service in all accounts | `string` | `"ALL"` | no |
| <a name="input_detectors"></a> [detectors](#input\_detectors) | The configuration for the GuardDuty detectors | <pre>map(object({<br/>    name = string<br/>    # The name of the detector<br/>    auto_enable = optional(string, "NONE")<br/>    # The frequency of finding publishing<br/>    additional_configuration = optional(map(object({<br/>      auto_enable = optional(string, "NONE")<br/>      # The status of the additional configuration<br/>    })), {})<br/>  }))</pre> | <pre>{<br/>  "eks": {<br/>    "auto_enable": "ALL",<br/>    "name": "EKS_AUDIT_LOGS"<br/>  },<br/>  "eks_runtime_monitoring": {<br/>    "additional_configuration": {<br/>      "EKS_ADDON_MANAGEMENT": {<br/>        "auto_enable": "NONE"<br/>      }<br/>    },<br/>    "auto_enable": "NONE",<br/>    "name": "EKS_RUNTIME_MONITORING"<br/>  },<br/>  "lambda": {<br/>    "auto_enable": "NONE",<br/>    "name": "LAMBDA_NETWORK_LOGS"<br/>  },<br/>  "malware": {<br/>    "auto_enable": "NONE",<br/>    "name": "EBS_MALWARE_PROTECTION"<br/>  },<br/>  "rds": {<br/>    "auto_enable": "NONE",<br/>    "name": "RDS_LOGIN_EVENTS"<br/>  },<br/>  "runtime_monitoring": {<br/>    "additional_configuration": {<br/>      "EC2_AGENT_MANAGEMENT": {<br/>        "auto_enable": "NONE"<br/>      },<br/>      "ECS_FARGATE_AGENT_MANAGEMENT": {<br/>        "auto_enable": "NONE"<br/>      },<br/>      "EKS_ADDON_MANAGEMENT": {<br/>        "auto_enable": "NONE"<br/>      }<br/>    },<br/>    "auto_enable": "NONE",<br/>    "name": "RUNTIME_MONITORING"<br/>  },<br/>  "s3": {<br/>    "auto_enable": "NONE",<br/>    "name": "S3_DATA_EVENTS"<br/>  }<br/>}</pre> | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | The frequency of finding publishing | `string` | `"FIFTEEN_MINUTES"` | no |
| <a name="input_guardduty_detector_id"></a> [guardduty\_detector\_id](#input\_guardduty\_detector\_id) | Used when not creating a new detector | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | The ID of the GuardDuty detector |
<!-- END_TF_DOCS -->