################################################################################
# WAFv2 — SQL injection protection

# This rule doesnt make a lot of practical sense for a static website but I added it just to get experience making WAF web acls
# and attaching them to CloudFront distributions using terraform
################################################################################

resource "aws_wafv2_web_acl" "sqli" {
  name        = "${var.bucket_name}-sqli-protection"
  description = "Blocks requests matching the AWS managed SQL injection rule set."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.bucket_name}-sqli-protection"
    sampled_requests_enabled   = true
  }
}

output "waf_web_acl_arn" {
  value = aws_wafv2_web_acl.sqli.arn
}