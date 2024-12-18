
locals {
  ## Indicates if we should create the Guardduty detecter
  create = var.guardduty_detector_id == null
  ## Is the guardduty detector id
  guardduty_detector_id_derived = try(coalesce(var.guardduty_detector_id, try(data.aws_guardduty_detector.guardduty[0].id, null)), null)
  ## The guardduty detector id
  guardduty_detector_id = local.create ? aws_guardduty_detector.guardduty[0].id : local.guardduty_detector_id_derived

}
