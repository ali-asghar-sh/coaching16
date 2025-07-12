resource "aws_wafv2_web_acl_logging_configuration" "api_gw_waf_logging" {
  resource_arn = aws_wafv2_web_acl.api_gw_waf.arn
  log_destination_configs = [
    aws_cloudwatch_log_group.waf_logs.arn
  ]

  logging_filter {
    # Default behavior when no filters match
    default_behavior = "DROP" # means "do not log" if no filter matches

    filter {
      behavior    = "KEEP" # keep logs if the condition matches
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
    }
  }
}
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "aws-waf-logs-api-group2-gw"  # Fixed: Added valid name
  retention_in_days = 14
  tags = {
    Environment = "prod"
  }
  # Optional: Uncomment if using KMS
  # kms_key_id = aws_kms_key.log_key.arn
}