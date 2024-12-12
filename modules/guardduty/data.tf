
## Lookup the detector id for the guardduty detector if provisioned already
data "aws_guardduty_detector" "guardduty" {
  count = local.create == false ? 1 : 0
}

