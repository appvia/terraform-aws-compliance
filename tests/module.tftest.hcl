run "basic" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.securityhub_findings[0].name == "lza-securityhub-all-notifications"
    error_message = "The security hub findings event bridge rule is not created"
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.securityhub_findings[0].tags) > 0
    error_message = "The security hub findings event bridge rule does not have any tags"
  }

  assert {
    condition     = aws_cloudwatch_event_target.securityhub_findings_target[0].rule == "lza-securityhub-all-notifications"
    error_message = "The security hub findings event bridge rule target is not set"
  }

  assert {
    condition     = aws_cloudwatch_event_target.securityhub_findings_target[0].target_id == "sns-target"
    error_message = "The security hub findings event bridge rule target is not set to sns"
  }

  variables {
    region = "eu-west-2"

    tags = {
      Project     = "Demo"
      Environment = "Development"
      Terraform   = "true"
    }

    notifications = {
      slack = {
        webhook_url = "https://hooks"
      }
    }

    config = {
      rule_groups = {
        root = {
          description = "Common managed rules distribued to all accounts"
          associations = [
            "r-h53v"
          ]

          rules = {
            "managed-resource-tagging" : {
              description = "Validate the resource tags"
              resource_types : [
                "AWS::ACM::Certificate",
                "AWS::CloudFront::Distribution",
                "AWS::CloudFront::StreamingDistribution",
                "AWS::DynamoDB::Table",
                "AWS::EC2::Instance",
                "AWS::EC2::VPC",
                "AWS::EC2::Volume",
                "AWS::ECR::PublicRepository",
                "AWS::EC2::NatGateway",
                "AWS::ECR::Repository",
                "AWS::ECS::Cluster",
                "AWS::EFS::FileSystem",
                "AWS::EKS::Cluster",
                "AWS::ElasticLoadBalancingV2::LoadBalancer",
                "AWS::Elasticsearch::Domain",
                "AWS::Kinesis::Stream",
                "AWS::Kinesis::StreamConsumer",
                "AWS::RDS::DBCluster",
                "AWS::RDS::DBInstance",
                "AWS::RDS::DBSnapshot",
                "AWS::Redshift::Cluster",
                "AWS::Route53::HostedZone",
                "AWS::S3::Bucket",
              ]
              identifier : "REQUIRED_TAGS"
              inputParameters = {
                tag1Key = "Product"
                tag2Key = "Owner"
                tag3Key = "Environment"
                tag4Key = "GitRepo"
              }
              mode = "DETECTIVE"
              # One_Hour | Three_Hours | Six_Hours | Twelve_Hours | TwentyFour_Hours
              max_execution_frequency : 24
            }
          }
        }
      }
    }

    securityhub = {
      notifications = {
        enable     = true
        severities = ["HIGH", "CRITICAL"]
      }

      aggregator = {
        create            = true
        linking_mode      = "ALL_REGIONS"
        specified_regions = ["eu-west-2", "us-east-1"]
      }

      configuration = {
        auto_enable           = false
        auto_enable_standards = "NONE"
        organization_configuration = {
          configuration_type = "CENTRAL"
        }
      }

      policies = {
        "lza-foundational" = {
          enable      = true
          description = "LZA Foundational Security Hub Policy, applied to all accounts"

          associations = [
            { organization_unit = "r-h53v" }
          ]

          policy = {
            standard_arns = [
              "aws_foundational_best_practices",
            ]
            controls = {
              disabled = [
                "Account.1",        # (security contact details) not supported by lza yet
                "CloudTrail.1",     # (Cloudtrail enabled) disabled, as we use organizational trails, not required
                "Config.1",         # (AWS Config enabled) enabled by control tower and configure by lza, not required
                "DynamoDB.1",       # (Autoscaling) - enabled in protection environments only
                "DynamoDB.6",       # (Deletion protection), disabled outright, not required as we use IaC + review and approval
                "EC2.10",           # (VPC Endpoints in VPC), for cost efficiency, we use a shared services account
                "EC2.2",            # (VPC default security groups, inbound + outbound rules open) not required, leave to review
                "EC2.21",           # (Network ACLs, port 22) Not required, overly restrictive and generally no required
                "EC2.6",            # (VPC Flow logs) - enabled if required for the organization unit
                "ECR.1",            # (ECR Image scanning) - enabled in production workloads only
                "ECR.2",            # (Immuntability) - enabled in production workloads only
                "ECR.3",            # (ECR lifecycle rules) - enabled in production workloads only
                "ELB.4",            # (Drop invalid header) - enabled in all accounts
                "ELB.5",            # (ELB Logging) - enabled in production workloads only
                "GuardDuty.10",     # (S3 protection) - not required
                "GuardDuty.5",      # (EKS protection) - not required
                "GuardDuty.6",      # (Lambda protection) - not required
                "GuardDuty.8",      # (Malware protection) - not required
                "GuardDuty.9",      # (RDS protection) - not required
                "IAM.1",            # (IAM "*" administrative privileges) - not required, too many false positives
                "IAM.21",           # (Wildcard IAM) - not required, too many false positives
                "IAM.6",            # (Hardware MFA)- not required due to identity central and sso
                "Inspector.1",      # (inspector ec2) - not required
                "Inspector.2",      # (inspector ec2) - not required
                "Inspector.3",      # (inspector lambda) - not required
                "Inspector.4",      # (inspector lambda standard) - not required
                "KMS.1",            # (Decrypt permissions on all keys) - not required, too many false positives
                "KMS.3",            # (KMS key deletion) - enabled per organization unit (prod, infra, security, deployments)
                "Macie.1",          # (Macie enabled) - not required unless required by the organization
                "Macie.2",          # (Macie sensitive data) - not required unless required by the organization
                "RDS.13",           # (RDS Automatic minor version upgrade) - enabled in production workloads only
                "RDS.15",           # (RDS Cluster Multi-AZ) - enabled in production workloads only
                "RDS.5",            # (RDS Multi-AZ) - enabled in production workloads only)
                "RDS.6",            # (RDS Enhanced monitoring) - enabled in production workloads only)
                "RDS.7",            # (RDS Deletion Protection) - IaC + review and approval
                "S3.13",            # (Lifecycle policies enabled) - IaC + review and approval
                "S3.5",             # (TLS in resource policy) - not required, enforced by SCP globally
                "S3.9",             # (Logging enabled) - IaC + review and approval
                "SSM.1",            # (SSM Managed) - not needed unless required by the organization
                "SecretsManager.1", # (Rotation enabled) - IaC + review and approval
              ]
              custom_parameter = []
            }
          }
        }
      }
    }
  }
}

mock_provider "aws" {
  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name   = "eu-west-2"
      region = "eu-west-2"
    }
  }
}

override_module {
  target = module.securityhub_notifications[0]
  outputs = {
    sns_topic_arn = "arn:aws:sns:eu-west-2:123456789012:appvia-notifications"
  }
}

Override_data
  target = deployment_targets.0.accounts.0
  value = "345678901221"

}