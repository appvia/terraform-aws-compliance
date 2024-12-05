#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "compliance" {
  source = "../.."

  securityhub = {
    policies = {
      "lza-foundational" = {
        service_enable = true
        description    = "LZA Foundational Security Hub Policy, applied to all accounts"

        associations = [
          { organization_unit = "ou-123456789012" }
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
              "IAM.9",            # (Root MFA) - not required, enforced by SCP
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
              "S3.10",            # (Versioning enabled) - enabled per organization unit (prod, infra, security, deployments)
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
