resource "aws_wafv2_web_acl" "three_tier_waf" {

  provider = aws.us_east_1

  name  = "3-tier-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {

    name     = "AWSManagedCommonRules"
    priority = 1

    override_action {
      none {}
    }

    statement {

      managed_rule_group_statement {

        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {

      cloudwatch_metrics_enabled = true

      metric_name = "AWSManagedCommonRules"

      sampled_requests_enabled = true
    }
  }

  visibility_config {

    cloudwatch_metrics_enabled = true

    metric_name = "3-tier-waf"

    sampled_requests_enabled = true
  }
}
