<!-- markdownlint-disable -->

<a href="https://www.appvia.io/"><img src="./docs/banner.jpg" alt="Appvia Banner"/></a><br/><p align="right"> </a> <a href="https://github.com/appvia/terraform-aws-module-template/releases/latest"><img src="https://img.shields.io/github/release/appvia/terraform-aws-module-template.svg?style=for-the-badge&color=006400" alt="Latest Release"/></a> <a href="https://appvia-community.slack.com/join/shared_invite/zt-1s7i7xy85-T155drryqU56emm09ojMVA#/shared-invite/email"><img src="https://img.shields.io/badge/Slack-Join%20Community-purple?style=for-the-badge&logo=slack" alt="Slack Community"/></a> <a href="https://github.com/appvia/terraform-aws-module-template/graphs/contributors"><img src="https://img.shields.io/github/contributors/appvia/terraform-aws-module-template.svg?style=for-the-badge&color=FF8C00" alt="Contributors"/></a>

<!-- markdownlint-restore -->
<!--
  ***** CAUTION: DO NOT EDIT ABOVE THIS LINE ******
-->

![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform AWS Compliance Module

## Description

The purpose of this module to provide an opinionated way to configure compliance and security related services within an organizational landing zone. The module among other things configures AWS Security Hub, AWS Config, AWS Config Rules, AWS Config Aggregator and AWS Config Conformance Packs

## Usage

Add example usage here

```hcl
module "example" {
  source  = "appvia/<NAME>/aws"
  version = "0.0.1"

  # insert variables here
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | Configuration for the securityhub organization managed rules | <pre>object({<br/>    managed_rules = optional(map(object({<br/>      description = string<br/>      # The description of the organization managed rules<br/>      rule_identifier = string<br/>      # The identifier of the organization managed rule<br/>      excluded_accounts = optional(list(string), null)<br/>      # The list of accounts to exclude from the organization managed rule<br/>      input_parameters = optional(string, null)<br/>      # A string in JSON format that is passed to the AWS Config Rule Lambda Function<br/>      rule_identifier_scope = string<br/>      # The identifier of the organization managed rule scope<br/>      resource_id_scope = optional(string, null)<br/>      # The identifier of the organization managed rule scope<br/>      resource_types_scope = optional(list(string), null)<br/>      # The list of resource types to scope the organization managed rule<br/>    })), {})<br/>    # The configuration for the securityhub organization managed rules<br/>  })</pre> | <pre>{<br/>  "managed_rules": {}<br/>}</pre> | no |
| <a name="input_securityhub"></a> [securityhub](#input\_securityhub) | Configuration for the securityhub | <pre>object({<br/>    aggregator = optional(object({<br/>      create = optional(bool, false)<br/>      # Indicates whether to create the securityhub<br/>      # Indicates whether to create the aggregator<br/>      linking_mode = optional(string, "ALL_REGIONS")<br/>      # Indicates whether to aggregate findings from all of the available regions<br/>      specified_regions = optional(list(string), null)<br/>      # A list of regions to aggregate findings from when using SPECIFIED_REGIONS linking mode<br/>    }), null)<br/>    # The configuration for the aggregator<br/>    configuration = optional(object({<br/>      auto_enable = optional(bool, false)<br/>      # Indicates whether to automatically enable Security Hub<br/>      auto_enable_standards = optional(string, "NONE")<br/>      # Indicates whether to automatically enable new controls and standards<br/>      organization_configuration = object({<br/>        configuration_type = optional(string, "CENTRAL")<br/>        # Indicates whether to enable Security Hub as a standalone service or as an organization master<br/>      })<br/>      # The configuration for the organization<br/>    }), null)<br/>    # The configuration for the securityhub<br/>    policies = optional(map(object({<br/>      description = string<br/>      # The description of the configuration policy<br/>      associations = optional(list(object({<br/>        account_id = optional(string, null)<br/>        # The account ID to associate with the policy<br/>        organization_unit = optional(string, null)<br/>        # The organization unit to associate with the policy<br/>      })), [])<br/>      # The list of associations for the configuration policy<br/>      policy = object({<br/>        enable = optional(bool, true)<br/>        # Indicates whether the configuration policy is enabled<br/>        standard_arns = list(string)<br/>        # The ARNs of the standards to enable<br/>        controls = object({<br/>          disabled = optional(list(string), null)<br/>          # The list of control identifiers to disable<br/>          custom_parameter = optional(list(object({<br/>            security_control_id = string<br/>            # The ID of the security control<br/>            parameter = object({<br/>              name = string<br/>              # The name of the parameter<br/>              value_type = string<br/>              # The type of the parameter<br/>              enum = optional(object({<br/>                value = string<br/>                # The value of the parameter (if the type is ENUM)<br/>              }), null)<br/>            })<br/>            # The parameter for the security control<br/>          })), null)<br/>        })<br/>        # The parameter for the security control<br/>      })<br/>      # The configuration policy<br/>    })), {})<br/>  })</pre> | <pre>{<br/>  "aggregator": {<br/>    "create": false,<br/>    "linking_mode": "ALL_REGIONS",<br/>    "specified_regions": null<br/>  },<br/>  "configuration": {<br/>    "auto_enable": false,<br/>    "auto_enable_standards": "NONE",<br/>    "organization_configuration": {<br/>      "configuration_type": "CENTRAL"<br/>    }<br/>  },<br/>  "policies": {}<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
