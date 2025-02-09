
locals {
  ## Determine if the macie service is managed by the landing zone
  analyzer_enabled = var.access_analyzer != null
}

## Provision the unused access analyzer
resource "aws_accessanalyzer_analyzer" "unused_access" {
  count = local.analyzer_enabled && try(var.access_analyzer.enable_unused_analyzer, false) ? 1 : 0

  analyzer_name = var.access_analyzer.unused_analyzer_name
  type          = "ORGANIZATION_UNUSED_ACCESS"
  configuration {
    unused_access {
      unused_access_age = var.access_analyzer.unused_access_age
    }
  }
}

