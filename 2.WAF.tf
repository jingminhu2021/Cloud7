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

resource "aws_wafv2_web_acl" "cognito_waf" {
  name  = "cognito-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cognitoVisibilityConfig"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "cognito_waf_association" {
  resource_arn = aws_cognito_user_pool.user_pool.arn
  web_acl_arn  = aws_wafv2_web_acl.cognito_waf.arn
}
