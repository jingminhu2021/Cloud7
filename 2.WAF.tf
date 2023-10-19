provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# This creates a WebACL for your CloudFront distributions
resource "aws_wafv2_web_acl" "cloudfront" {
  provider = aws.us-east-1
  name     = "cloudfront-webacl"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfrontVisibilityConfig"
    sampled_requests_enabled   = true
  }
}